class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column "name", :string, :limit => 100, :null => false
      t.column "conference_id", :integer, :null => false
      t.column "location", :string, :limit => 255
      t.column "start_time", :datetime
      t.column "end_time", :datetime
      t.column "description", :text
      t.column "active", :boolean, :default=>false, :null=>false      
    end
    add_index "events", "conference_id", :name => "event_conf_idx"
    add_index "events", ["start_time", "end_time"], :name => "event_time_idx"
    add_index "events", "active", :name => "event_active_idx"
  end

  def self.down
    drop_table :events
  end
end
