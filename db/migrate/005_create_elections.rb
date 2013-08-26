class CreateElections < ActiveRecord::Migration
  def self.up
    create_table :elections do |t|
      t.column "event_id", :integer, :null => false
      t.column "name", :string, :limit => 255
      t.column "type", :string, :limit => 50
      t.column "conditions", :text
      t.column "start_time", :datetime
      t.column "end_time", :datetime
    end
    add_index "elections", "event_id", :name => "election_event_idx"
    add_index "elections", ["start_time", "end_time"], :name => "election_times_idx"
  end

  def self.down
    drop_table :elections
  end
end
