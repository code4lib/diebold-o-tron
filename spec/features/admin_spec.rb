require 'spec_helper'

describe "Creating an election", type: :feature do
  before do
    OmniAuth.config.test_mode = true
    
    OmniAuth.config.mock_auth[:code4lib] = OmniAuth::AuthHash.new({
      :provider => 'code4lib',
      :uid => 'user_account_name'
    })
  end
  
  before :each do
    visit "/"
    click_on "Sign in"
  end
  
  after :each do
    click_on "Sign out"
  end
  
  it "should create a conference" do
    visit "/admin/"
    click_on "Add conference"
  end
end
