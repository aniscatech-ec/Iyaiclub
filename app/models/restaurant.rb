class Restaurant < ApplicationRecord
  belongs_to :establishment

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
