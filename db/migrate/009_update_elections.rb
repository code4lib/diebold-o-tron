class UpdateElections < ActiveRecord::Migration
  def self.up
	add_column :elections, :auth_required, :boolean, :default=> false
  end

  def self.down
	remove_column :elections, :auth_required
  end
end
