$LOAD_PATH.unshift File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'conference_keeper'
require 'rspec'
require 'rack/test'

require 'capybara'
require 'capybara/dsl'

Capybara.app = Sinatra::Application

require 'database_cleaner'

RSpec.configure do |config|
  config.include Capybara::DSL
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
