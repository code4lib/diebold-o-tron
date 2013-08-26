class Conference < ActiveRecord::Base
  has_many :events
end

class Election < ActiveRecord::Base
  belongs_to :event
  has_many :votes
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

class Event < ActiveRecord::Base
  belongs_to :conference
  has_many :items
  has_many :elections
end

class Item < ActiveRecord::Base
  belongs_to :event
  has_many :votes
  has_many :participants, :dependent => :destroy
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

class Participant < ActiveRecord::Base
  belongs_to :person
  belongs_to :item
end

class Person < ActiveRecord::Base
  has_many :votes
  has_many :participants
  
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

class Vote < ActiveRecord::Base
  belongs_to :election
  belongs_to :person
  belongs_to :item
end



