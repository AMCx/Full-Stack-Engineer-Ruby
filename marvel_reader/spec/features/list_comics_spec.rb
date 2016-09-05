require 'rails_helper'

feature "List Comics", :type => :feature do

  it 'should When I open the page I want to see a list of all Marvel’s released comic books covers ordered from most recent to the oldest so I can scroll trough the the Marvel universe' do

    visit root_path

    expect( page.body ).to include( I18n.t('page.comics.sub_title') )

  end

  it "should allow search by comic title" do
    visit root_path

    within ".search-area" do
      fill_in "search_name", with: "Hulk"
    end

    click_button "Search comics"

    expect(page).to have_selector('.comics-list-container')
    expect( page.body ).to include( "Hulk" )
  end

  it "should allow search by comic title, failing" do
    visit root_path

    within ".search-area" do
      fill_in "search_name", with: "no_comic_should_ever_be_found"
    end

    click_button 'Search comics'

    expect(page).to_not have_selector('.comics-list-container')
    expect( page.body ).to include( I18n.t('page.comics.no_results') )
  end

  it "should allow filter by character name" do
    visit root_path

    within "#search-filters" do
      fill_in "character_name", with: "Hulk"
    end

    expect(page).to have_selector('#search-filters .by-character-filter')

  end


end