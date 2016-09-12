require 'rails_helper'

RSpec.describe Favorite, type: :model do

  before(:each) do

  end

  it "should always have a comic_id" do
    i = Favorite.create
    expect(i).to_not be_valid

    i = Favorite.create comic_id: 1
    expect(i).to be_valid

  end

  it "should have a unique comic_id" do

    i = Favorite.create comic_id: 2
    expect(i).to be_valid

    i = Favorite.create comic_id: 2
    expect(i).to_not be_valid

  end

end
