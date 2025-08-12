class Amenity < ApplicationRecord
  has_many :establishment_amenities
  has_many :establishments, through: :establishment_amenities

end
