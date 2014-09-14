# define some models so we don't need to load up the actual models
class Election < ActiveRecord::Base; end
class Item < ActiveRecord::Base; end
class Presentation < Item; end
class TShirt < Item; end
class Keynote < Item; end
class Location < Item; end

class UpdateItems < ActiveRecord::Migration
  
  def self.up
    
    add_column :items, :election_id, :integer, :default=> false
    
    transfer_data_from_type_to_election
    
    remove_column :items, :type
    remove_column :items, :start_time
    remove_column :items, :end_time   
    remove_column :items, :location
  end

  def self.down
    remove_column :items, :election_id
  end
  
  def self.transfer_data_from_type_to_election
    
    Election.all.each do |e|
      e.event.items.where(e.conditions).order("name").each do |i|
        i.update_attributes election_id: i
      end  
    end
  end
end
