class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.column "name", :string, :limit => 100, :null => false
    end
  end

  def self.down
    drop_table :conferences
  end
end
