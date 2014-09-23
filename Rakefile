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

begin
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
rescue LoadError
end
