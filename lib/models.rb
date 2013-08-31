class Conference
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :events
end

class Election
  include DataMapper::Resource
  property :id, Serial
  property :event_id, Integer
  property :name, String
  property :type, Discriminator
  property :criteria, Text, :field=>'conditions'
  property :start_time, DateTime
  property :end_time, DateTime
  property :auth_required, Boolean, :default=>false
  belongs_to :event
  has n, :votes
  # @@children = []
  # 
  # def self.inherited(sub)
  #   @@children << sub
  # end
  # 
  # def self.children
  #   return @@children
  # end 

  def open?
    right_now = Time.now
    return true if (self.start_time && right_now >= self.start_time) && (self.end_time && right_now <= self.end_time)
    return false
  end
end

class Event
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :conference_id, Integer
  property :location, String
  property :start_time, DateTime
  property :end_time, DateTime
  property :description, Text
  property :active, Boolean, :default=>false
  belongs_to :conference
  has n, :items
  has n, :elections
end

class Item
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :event_id, Integer
  property :description, Text
  property :type, Discriminator
  property :start_time, DateTime
  property :end_time, DateTime
  property :location, String
  property :active, Boolean, :default=>true
  
  belongs_to :event
  has n, :votes
  has n, :participants
  # @@children = []
  # 
  # def self.inherited(sub)
  #   @@children << sub
  # end
  # 
  # def self.children
  #   return @@children
  # end
  
  def has_role?(person, role)
    self.participants.each do | part |
      return true if person.id == part.person_id and role.downcase == part.role.downcase
    end
    return false
  end
  
  def clear_role(role)
    entries = []
    self.participants.each do | part |
      entries << part if part.role.downcase == role.downcase
    end
    self.participants.delete(entries) unless entries.empty?
  end
end

class Keynote < Item;end

class Location < Item;end

class Participant
  include DataMapper::Resource
  property :id, Serial
  property :person_id, Integer
  property :item_id, Integer
  property :role, String
  
  belongs_to :person
  belongs_to :item
end

class Person
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :length=>50
  property :first_name, String, :length=>100
  property :middle_name, String, :length=>100
  property :last_name, String, :length=>100
  property :email, String, :length=>255
  property :organization, String, :length=>255
  property :title, String, :length=>255
  
  has n, :votes
  has n, :participants
  
  def last_first
    name = "#{self.last_name}, #{self.first_name}"
    name << " #{self.middle_name}" unless self.middle_name.blank?
    return name
  end
  
  def full_display
    name = self.first_name
    name << " #{self.middle_name}" unless self.middle_name.blank?
    name << " #{self.last_name}" if self.last_name
    assoc = ''
    assoc = self.title if self.title
    if self.organization
      assoc << ", " unless assoc.empty?
      assoc << self.organization
    end
    name << ":  #{assoc}" unless assoc.empty?
    return name
  end
    
end

class Presentation < Item
  def presenters
    people = []
    self.participants.each do | part |
      people << part.person if part.role.downcase == "presenter"
    end
    return people
  end
end

class RatingElection < Election;end

class TShirt < Item;end

class Vote
  include DataMapper::Resource
  property :id, Serial
  property :election_id, Integer
  property :person_id, Integer
  property :item_id, Integer
  property :score, Integer, :default=>1
  property :created_at, DateTime, :default=>DateTime.now
  belongs_to :election
  belongs_to :person
  belongs_to :item
end



