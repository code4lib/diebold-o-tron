class Conference < ActiveRecord::Base
  has_many :events
end

class Election < ActiveRecord::Base
  belongs_to :event
  has_many :items
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
end

class Person < ActiveRecord::Base
  has_many :votes
  
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

class RatingElection < Election;end

class PresentationElection < RatingElection;end
class LocationElection < RatingElection;end
class KeynoteElection < RatingElection;end
class TShirtElection < RatingElection;end

class Vote < ActiveRecord::Base
  belongs_to :election
  belongs_to :person
  belongs_to :item
end
