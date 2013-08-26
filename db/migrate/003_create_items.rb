class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column "name", :string, :limit => 255, :null => false
      t.column "event_id", :integer, :null => false
      t.column "description", :text
      t.column "type", :string, :limit => 50, :null => false
      t.column "start_time", :datetime
      t.column "end_time", :datetime      
      t.column "location", :string, :limit => 255
      t.column "active", :boolean, :default=>true, :null=>false            
    end
    
    add_index "items", ["start_time", "end_time"], :name => "item_time_idx"
    add_index "items", "event_id", :name => "item_event_idx"
    add_index "items", "type", :name => "item_type_idx"
    add_index "items", "active", :name => "item_active_idx"
  end

  def self.down
    drop_table :items
  end
end
