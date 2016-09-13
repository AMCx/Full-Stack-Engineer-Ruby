require 'rails_helper'

feature "List Comics", :type => :feature do

  it 'should When I open the page I want to see a list of all Marvel’s released comic books covers ordered from most recent to the oldest so I can scroll trough the the Marvel universe' do

    visit root_path

    expect(page).to have_selector('.comics-list-container')

  end

  it "should allow filter by character name" do
    visit root_path

    within "#search-filters" do
      fill_in "character_name", with: "Hulk"
    end

    expect(page).to have_selector('#search-filters .by-character-filter')

  end

end