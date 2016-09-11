class Favorite < ApplicationRecord
  validates_uniqueness_of :comic_id
end
