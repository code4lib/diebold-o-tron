class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column "election_id", :integer, :null => false
      t.column "person_id", :integer, :null => false
      t.column "item_id", :integer, :null => false
      t.column "score", :integer, :null => false, :default => 1
      t.column "created_at", :datetime, :null => false      
    end
    add_index "votes", ["election_id", "person_id", "item_id"], :name => "vote_ballot_idx"    
  end

  def self.down
    drop_table :votes
  end
end
