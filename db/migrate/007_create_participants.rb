class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.column "person_id", :integer, :null => false
      t.column "item_id", :integer, :null => false
      t.column "role", :string, :limit => 25      
    end
    add_index "participants", ["person_id", "item_id", "role"], :name => "participant_role_idx"
  end

  def self.down
    drop_table :participants
  end
end
