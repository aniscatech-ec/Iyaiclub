class RestaurantMenuCategory < ApplicationRecord
  belongs_to :restaurant
  belongs_to :menu_category
end
