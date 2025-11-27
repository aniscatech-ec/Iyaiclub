class MenuCategory < ApplicationRecord
  has_many :restaurant_menu_categories
  has_many :restaurants, through: :restaurant_menu_categories

  has_many :menu_items
end
