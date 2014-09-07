require 'rake'

task :environment do
  require './conference_keeper'
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    require 'logger'

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
