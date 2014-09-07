require 'spec_helper'

describe "Home Page", type: :feature do
  it "should have a home page" do
    visit '/'
  end
end
