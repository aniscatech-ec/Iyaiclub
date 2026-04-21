class TravelAgency < ApplicationRecord
  belongs_to :establishment
  has_many :tour_packages, dependent: :destroy

  enum :subcategory, { agencia: 0, guia: 1 }

  validates :subcategory, presence: { message: "Debe seleccionar una subcategoría" }

  delegate :user,
           :images,
           :establishment_amenities,
           :amenities,
           :galleries,
           :payment_methods,
           :legal_info,
           :verification,
           :pricing_policy,
           to: :establishment

  accepts_nested_attributes_for :establishment
end
