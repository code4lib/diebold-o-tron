require 'spec_helper'

describe "Signing in" do
  before do
    OmniAuth.config.test_mode = true
    
    OmniAuth.config.mock_auth[:code4lib] = OmniAuth::AuthHash.new({
      :provider => 'code4lib',
      :uid => '12345'
    })
  end

  it "should sign in and out" do
    visit "/"
    click_on "Sign in"
    expect(page).to have_content "Signed in as 12345"
    click_on "Sign out"
    expect(page).to have_content "Sign in"
  end
  
  it "should return the user to the page they signed in from" do
    visit "/conferences/events/"
    click_on "Sign in"
    expect(page).to have_content "All events"
  end
end
