require 'rubygems'
require 'sinatra'
require 'active_record'
require 'yaml'
require 'rack/conneg'
require 'lib/models'
require 'lib/drupal_client'
require 'json'

configure do
  CONFIG = YAML.load_file('config/config.yml')
  ActiveRecord::Base.establish_connection(CONFIG['database'])  
  enable :sessions  
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
  @user = Person.find_by_username(session[:username]) if session[:username]
  @items = @election.event.items.find(:all, :conditions=>@election.conditions, :order=>"name")  

  if @election.open?
    haml :"election/ballot"
  else
    haml :"election/closed"
  end
end

get "/election/results/:id" do
  unless params[:id]
    redirect_to :action=>'list_elections'
    return    
  end
  @election = Election.find(params[:id])
  @page_title = "Results:  #{@election.name}"
  @results = {}
  items = []
  @election.votes.each do | v |
    items << v.item unless items.index(v.item)
  end
  @scores = []
  machine_readable = []
  items.each do | i |
    score = @election.votes.sum(:score, :conditions=>["item_id = ?", i.id]).to_s
    @scores << score.to_i unless @scores.index(score.to_i)
    @results[score] ||=[]
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
  client = DrupalClient.new(CONFIG["Drupal"]["host"], params[:username], params[:password])
  login = client.login
  if login == 0
    redirect "/login/error/"
    return
  end
  session[:username] = params[:username]
  session[:drupal_id] = params[:login]
  unless Person.find_by_username(params[:username])
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


get "/login/error/" do
  @message = "Incorrect username or password"
  haml :"common/login_form", {:layout => :"common/layout-noleft"}    
end

get "/admin/" do
  check_admin
  haml :"admin/index", {:layout => :"common/layout"}  
end

post "/admin/set_event" do
  check_admin
  session[:event_id] = params[:event_id]
  redirect "/admin/"
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

get "/admin/election/" do
  check_admin
  @elections = Election.find_all_by_event_id(session[:event_id], :order=>"id")
  haml :"admin/elections", {:layout => :"common/layout"}    
end

get "/admin/election/edit/" do
  check_admin
  if params[:id]
    @election = Election.find(params[:id])
  else
    @election = Election.new
  end
  haml :"admin/edit_election", {:layout => :"common/layout"}
end

post "/admin/election/edit/" do
  check_admin
  if params[:id]
    election = Election.find(params[:id])
    election.name = params[:name]
    election.type = params[:type]
    election.start_time = DateTime.parse(params[:start_time])
    election.end_time = DateTime.parse(params[:end_time])    
    election.event_id = session[:event_id]
    election.conditions = "type = '#{params[:election_type]}' AND event_id = #{session[:event_id]}"
    election.save
  else
    params[:conditions] = "type = '#{params[:election_type]}' AND event_id = #{session[:event_id]}"
    params.delete(:election_type)
    election = Election.create(params)
  end
  session[:message] = "#{election.name} saved!"
  redirect "/admin/updated/"
end

get "/admin/updated/" do
  @message = session[:message].dup
  session[:message] = nil
  haml :"admin/updated", {:layout => :"common/layout"}
end

helpers do
  def check_admin
    return if CONFIG['administrators'] && CONFIG['administrators'].include?(session[:username])
    halt 401, "Unauthorized"
  end
end