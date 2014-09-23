require 'spec_helper'

describe "Elections" do
  before :each do
    @conference = Conference.create name: "Test conference"
    @event = Event.create name: "Test Event", conference: @conference
    @election_a = Election.create name: "Election A", event: @event, start_time: Time.now - 120, end_time: Time.now - 1
    @election_b = Election.create name: "Election B", event: @event, start_time: Time.now, end_time: (Time.now + 120)    
  end
  
  describe "index" do
    it "should list all elections" do
      visit '/election/'
      
      expect(page).to have_content "Open Elections"
      expect(page).to have_content "Closed Elections"
    end
  end
end
