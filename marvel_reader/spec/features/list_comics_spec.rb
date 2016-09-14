require 'rails_helper'

feature "List Comics", :type => :feature do

  before(:each) do
    DatabaseCleaner.clean
  end

  it 'should When I open the page I want to see a list of all Marvel’s released comic books covers ordered from most recent to the oldest so I can scroll trough the the Marvel universe' do
    
    visit root_path
    expect(page).to have_css('#comic_43092 .comic-info-container', text: 'Brilliant (2011) #7')
    expect(page).to have_css('#comic_41530 .comic-info-container', text: 'Ant-Man: So (Trade Paperback)')

  end

  it 'When I see the list of comics I want to be able to search by character (ex. deadpool) so that I can find my favorite comics', js: true do
  
    visit root_path
    within "#comics-search-form" do
      fill_in "search[name]", with: "Hulk"
    end

    wait_for_ajax
    expect(page).to have_css('#ui-character-1009351', text: 'Hulk')
    find( '#ui-character-1009351').click
    
    wait_for_ajax
    find( '#comic_60380').hover
    expect(page).to have_css('#comic_60380 .comic-info-container', text: 'FALLEN (2016) #1')
  
  end

  it 'When I see the list of comics I want to be able to upvote any of them so that the most popular are easy to find in the future', js: true do

    visit root_path
    find( '#comic_43092').hover
    expect(page).to have_css('#comic_43092 .heart-off')
    find( '#comic_43092 .favorites').click

    wait_for_ajax
    expect(page).to have_css('#comic_43092 .heart-on')

    visit root_path
    find( '#comic_43092').hover
    expect(page).to have_css('#comic_43092 .heart-on')
    find( '#comic_43092 .favorites').click

    wait_for_ajax
    expect(page).to have_css('#comic_43092 .heart-off')

  end

end