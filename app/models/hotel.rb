class Hotel < ApplicationRecord
  belongs_to :establishment

  enum :hotel_type, {
    hotel: "hotel",
    conventional: "conventional",
    hostal: "hostal",
    glamping: "glamping",
    ecohotel: "ecohotel"
  }

  validates :hotel_type, presence: { message: "Debe seleccionar el tipo de hospedaje" }
  validates :total_rooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :available_rooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :max_guests, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true

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
  accepts_nested_attributes_for :establishment
end
