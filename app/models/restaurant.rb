class Restaurant < ApplicationRecord
  belongs_to :establishment

  has_many :restaurant_menu_categories #tabla intermedia
  has_many :menu_categories, through: :restaurant_menu_categories # relacion *-*

  has_many :menu_items

  delegate :user,
           :images,
           :establishment_amenities,
           :amenities,
           :units,
           :galleries,
           :payment_methods,
           :legal_info,
           :verification,
           :pricing_policy,
           to: :establishment
  # accepts_nested_attributes_for :units
  # accepts_nested_attributes_for :galleries
  accepts_nested_attributes_for :establishment
end
