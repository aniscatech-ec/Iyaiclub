class Hotel < ApplicationRecord
  belongs_to :establishment

  has_many :units, dependent: :destroy

  delegate :user,
           :images,
           :establishment_amenities,
           :amenities,
           # :units,
           :galleries,
           :payment_methods,
           :legal_info,
           :verification,
           :pricing_policy,
           to: :establishment
  accepts_nested_attributes_for :establishment
  accepts_nested_attributes_for :units, allow_destroy: true
end
