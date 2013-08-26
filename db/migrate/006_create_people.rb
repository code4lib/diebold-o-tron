class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column "username", :string, :limit => 50
      t.column "first_name", :string, :limit => 100
      t.column "middle_name", :string, :limit => 100
      t.column "last_name", :string, :limit => 100
      t.column "email", :string, :limit => 255
      t.column "organization", :string, :limit => 255
      t.column "title", :string, :limit => 255
    end
    add_index "people", ["username", "email"], :name => "people_user_idx"
  end

  def self.down
    drop_table :people
  end
end
