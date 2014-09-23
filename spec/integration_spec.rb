require 'spec_helper'

describe "Diebold-o-tron" do
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  it "has an index page" do
    get '/'
    expect(last_response).to be_ok
  end
end
