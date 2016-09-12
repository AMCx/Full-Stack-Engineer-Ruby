class Favorite < ApplicationRecord
  validates_uniqueness_of :comic_id
  validates_presence_of :comic_id
end
