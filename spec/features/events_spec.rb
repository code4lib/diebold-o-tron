require 'spec_helper'

describe "Events" do
  before :each do
    @conference = Conference.create name: "Test conference"
    @event = Event.create name: "Test Event", conference: @conference
    @election_a = Election.create name: "Election A", event: @event, start_time: Time.now - 120, end_time: Time.now - 1
    @election_b = Election.create name: "Election B", event: @event, start_time: Time.now, end_time: (Time.now + 120)    
  end
  
  it "should list all events" do
    visit '/conferences/events/'
    expect(page).to have_content "Test conference"
    expect(page).to have_link "Test Event"
  end
  
  it "should show the elections for an event" do
    visit '/conferences/events/'
    click_on "Test Event"
    
    expect(page).to have_content "Election A"
    expect(page).to have_content "Election B"
  end
end
