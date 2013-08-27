$KCODE = 'u'
require 'rubygems'
require 'jcode'
require 'sinatra'
require 'haml'
require 'active_record'
require 'yaml'
require 'rack/conneg'
require 'lib/models'
require 'lib/drupal_client'
require 'rdiscount'
require 'json'

configure do
  CONFIG = YAML.load_file('config/config.yml')
  ActiveRecord::Base.establish_connection(CONFIG['database'])  
  enable :sessions  
  set :session_secret, "wheedly-wheedly-whee!"
  set :haml, :format => :html5
end

use(Rack::Conneg) { |conneg|
  conneg.set :accept_all_extensions, false
  conneg.set :fallback, :html
  conneg.ignore('/public/')
  conneg.ignore('/css/')
  conneg.ignore('/js/')
  conneg.provide([:json, :xml, :html])
}

before do  
  content_type negotiated_type
end

get "/" do
  haml :"index", {:layout => :"common/layout"}  
end

get "/election/" do
  @open = []
  @closed = []
  Election.find(:all).each do | elect |
    if elect.open?
      @open << elect
    else
      @closed << elect
    end
  end
  haml :"election/index", {:layout => :"common/layout"}  
end

get "/election/:id" do
  unless params[:id]
    redirect "/election"
    return
  end
  @election = Election.find(params[:id])
  @page_title = "Election:  #{@election.name}"
  @page_title = @election.name
  @event = @election.event
  check_auth_required(@election,session,"/election/#{@election.id}")
	
  @items = @election.event.items.find(:all, :conditions=>@election.conditions, :order=>"name")  

  if @election.open?
    haml :"election/ballot", {:layout => :"common/layout"}  
  else
    haml :"election/closed"
  end
end

post "/election/:id" do
  @election = Election.find(params[:id])
  @event = @election.event 
  @page_title = "Ballot error:  #{@election.name}"
  unless person = Person.find_by_username(session[:username])      
    @message = "You are not signed in properly!"
    return haml :"election/error", {:layout => :"common/layout"}  
  end
    
  unless @election.open?
    @message = "This election is not currently open, sorry."
    return haml :"election/error", {:layout => :"common/layout"}           
  end
  @page_title = "Ballot submitted:  #{@election.name}"
  params[:item].each do | item_id, score |
    
    vote = Vote.find_or_create_by_item_id_and_election_id_and_person_id(item_id.to_i, @election.id, person.id)
    next if score == "0" and vote.new_record?
    if score == "0" and !vote.new_record?
      Vote.delete(vote.id)
      next
    end
    vote.item = Item.find(item_id)
    vote.person = person
    vote.election = @election
    vote.score = score.to_i
    vote.save
  end
  haml :"election/ballot_submitted", {:layout => :"common/layout"}  
end

get "/election/results/:id" do
  unless params[:id]
    redirect_to :action=>'list_elections'
    return    
  end
  @election = Election.find(params[:id])
  check_auth_required(@election,session, "/election/results/#{@election.id}")
  
  @event = @election.event
  

  @page_title = "Results:  #{@election.name}"
  @results = {}
  items = {}
  Item.find_by_sql("select distinct i.* FROM items i, votes v WHERE v.election_id = #{@election.id} AND i.id = v.item_id").each do |i|
    items[i.id] = i
  end

  @scores = []
  machine_readable = []
  @election.votes.sum(:score, :group=>:item_id).each_pair do |item_id, score|
    @scores << score.to_i unless @scores.index(score.to_i)
    @results[score] ||=[]
    i = items[item_id]
    @results[score] << i
    machine_readable << {:id=>i.id,:title=>i.name,:description=>i.description,:score=>score.to_i}
  end

  respond_to do |format|
    format.html { haml :"election/results", {:layout => :"common/layout"}  }
    format.json { machine_readable.to_json }
    format.xml  { machine_readable.to_xml }
  end  
end

get "/conferences/events/" do
  @events = Event.find(:all, :order=>"conference_id")
  @page_title = "All Events"  
  haml :"events/index", {:layout => :"common/layout"}    
end

get "/conferences/events/:id" do
  @event = Event.find(params[:id])
  @page_title = "#{@event.name} Home"
  haml :"events/event", {:layout => :"common/layout"}    
end

post "/login/" do
  if CONFIG['authentication'] && CONFIG['authentication'].include?('dummy')
	 $stderr.puts "BYPASSING LOGIN OH NOES"
	 login = 1
  else
  	client = DrupalClient.new(CONFIG["Drupal"]["host"], params[:username], params[:password])
  	login = client.login
  end 
  if login == 0
    redirect "/login/error/"
    return
  end
  session[:username] = params[:username]
  session[:drupal_id] = params[:login]
  unless Person.find_or_create_by_username(params[:username])
    redirect '/profile/edit'
    return
  end
  if params[:return] == "/login/error/"
    redirect "/"
  else
    redirect params[:return]
  end
end

get "/logout/" do
  session.clear
  redirect "/"
end

get '/profile/' do  
  @person = (Person.find_by_username(session[:username])||Person.new)
  haml :"profile/edit", {:layout => :"common/layout"}    
end

post '/profile/edit' do  
  person = Person.find_or_create_by_username(params[:username])
  person.update_attributes(params)
  person.save
  haml :"profile/saved", {:layout => :"common/layout"}   
end

get "/login/error/" do
  @message = "Incorrect username or password"
  if session[:message]
	  @message = session[:message]
	  session.delete(:message)
  end
  @next_page = params[:return]
  haml :"common/login_form", {:layout => :"common/layout"}    
end

get "/admin/" do
  check_admin
  haml :"admin/index", {:layout => :"common/layout"}  
end

post "/admin/set_event" do
  check_admin
  #session[:event_id] = params[:event_id]
  redirect "/admin/event/#{params[:event_id]}"
end

get "/admin/person/" do
  check_admin
  @people = Person.find(:all, :order => "last_name, first_name, middle_name, email")
  haml :"admin/people", {:layout => :"common/layout"}    
end

get "/admin/conference/" do
  check_admin
  @conferences = Conference.find(:all, :order=>"id")
  haml :"admin/conferences", {:layout => :"common/layout"}    
end

get "/admin/conference/edit/" do
  check_admin
  if params[:id]
    @conference = Conference.find(params[:id])
  end
  haml :"admin/edit_conference", {:layout => :"common/layout"}
end

post "/admin/conference/edit/" do
  check_admin
  if params[:id]
    conference = Conference.find(params[:id])
    conference.name = params[:name]
    conference.save
  else
    conference = Conference.create(:name=>params[:name])
  end
  session[:message] = "#{conference.name} saved!"
  redirect "/admin/updated/"
end

get "/admin/event/" do
  check_admin
  @events = Event.find(:all, :order=>"conference_id")
  haml :"admin/events", {:layout => :"common/layout"}    
end

get "/admin/event/edit/" do
  check_admin
  if params[:id]
    @event = Event.find(params[:id])
  else
    @event = Event.new
  end
  haml :"admin/edit_event", {:layout => :"common/layout"}
end

post "/admin/event/edit/" do
  check_admin
  if params[:id]
    event = Event.find(params[:id])
    event.name = params[:name]
    event.location = params[:location]
    event.description = params[:description]
    event.conference_id = params[:conference_id]
    event.active = true
    event.save
  else
    params[:active] = true
    event = Event.create(params)
  end
  session[:message] = "#{event.name} saved!"
  redirect "/admin/updated/"
end

get "/admin/event/:id" do
  check_admin
  begin    
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found unless @event
  end
  @item_types = Item.all(:conditions=>{:event_id=>@event.id}, :select=>:type).map(&:type).uniq
  haml :"admin/index", {:layout => :"common/layout"}
end

get "/admin/event/:id/election/" do
  check_admin
  @event = Event.find(params[:id])
  @elections = Election.find_all_by_event_id(params[:id], :order=>"id")
  haml :"admin/elections", {:layout => :"common/layout"}    
end

get "/admin/event/:id/proposals/" do
  check_admin
  @proposals = Item.find_all_by_event_id_and_type(params[:id], params[:type], :order=>"id")
  begin
    haml :"admin/proposals/#{params[:type].downcase}", {:layout => :"common/layout"}      
  rescue Errno::ENOENT
    haml :"admin/proposals", {:layout => :"common/layout"}    
  end
  
end

get "/admin/event/:event_id/proposals/edit/" do
  check_admin
  @event = Event.find(params[:event_id])
  if params[:id]
    @proposal = Item.find(params[:id])
  else
    @proposal = Kernel.const_get(params[:type]).new
  end
  begin
    haml :"admin/proposals/edit_#{params[:type].downcase}", {:layout => :"common/layout"}
  rescue Errno::ENOENT
    haml :"admin/edit_proposal", {:layout => :"common/layout"}    
  end    
end

post "/admin/event/:event_id/proposals/edit/" do
  check_admin
  if params[:id]
    proposal = Item.find(params[:id])    
  else
    proposal = Kernel.const_get(params[:type]).new
  end
  
  proposal.attributes = params.reject{|k,v| !proposal.attributes.keys.member?(k.to_s) }
  proposal.save
  
  session[:message] = "#{proposal.name} saved!"
  redirect "/admin/event/#{params[:event_id]}/updated/" 
end

get "/admin/event/:event_id/election/edit/" do
  check_admin
  @event = Event.find(params[:event_id])
  if params[:id]
    @election = Election.find(params[:id])
  else
    @election = Election.new
  end
  haml :"admin/edit_election", {:layout => :"common/layout"}
end

post "/admin/event/:event_id/election/edit/" do
  check_admin
  args = {}
  [:name, :event_id, :id, :type,:auth_required].each do |p|
    args[p] = params[p] if params[p]
  end
  
  start_time = params[:start_date]
  start_time << "T#{params[:start_time]}" if params[:start_time]
  args[:start_time] = DateTime.parse(start_time)
  
  end_time = params[:end_date]
  end_time << "T#{params[:end_time]}" if params[:end_time]  
  args[:end_time] = DateTime.parse(end_time)
  auth_required = params[:auth_required]
  
  if args[:id]
    election = Election.find(args[:id])
    election.name = args[:name]
    election.type = args[:type]

    election.start_time = args[:start_time]
    election.end_time = args[:end_time]   
    election.event_id = session[:event_id]
    election.auth_required = auth_required
    election.conditions = "type = '#{params[:election_type]}' AND event_id = #{args[:event_id]}"    
    election.save
  else
    args[:conditions] = "type = '#{params[:election_type]}' AND event_id = #{args[:event_id]}"    
    puts args.inspect
    election = Kernel.const_get(args[:type]).create(args)
  end
  session[:message] = "#{election.name} saved!"
  redirect "/admin/event/#{params[:event_id]}/updated/"
end

get "/admin/event/:event_id/updated/" do
  if session[:message]
    @message = session[:message].dup
  end
  @event = Event.find(params[:event_id])
  session[:message] = nil
  haml :"admin/updated", {:layout => :"common/layout"}
end

helpers do
  def check_admin
    return if CONFIG['administrators'] && CONFIG['administrators'].include?(session[:username])
    halt 401, "Unauthorized"
  end
  def display_election_item(item, user, election)
    return display_rating(item, user, election) if election.is_a?(RatingElection)
  end
  
  def set_span_size_for_live(is_open, user)
    if is_open && user
      'span7'
    else
      'span10'
    end
  end
  
  def conditional_ballot_form(active, attributes, &block)
    if active
      haml_tag :form, attributes, &block
    else 
      haml_concat capture_haml(&block)
    end
    
  end
  
  def display_rating(item, user, election)
    vote = Vote.find_by_item_id_and_person_id_and_election_id(item.id, user.id, election.id)
    selected = 0
    selected = vote.score if vote
    haml :"election/rating_item", :locals=>{:item_id=>item.id, :selected=>selected}
  end  

  def check_auth_required(election,session,next_page)
    if election.auth_required?
        @user = Person.find_by_username(session[:username]) if session[:username]
        unless @user
          session[:message] = "You must be logged in to view results for this election"
          next_url = "/login/error/"
          if next_page
            next_url += "?return=#{next_page}"
          end
          redirect next_url
        end
    end
  end

end
