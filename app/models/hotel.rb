class Hotel < ApplicationRecord
  belongs_to :establishment
  has_many :rooms, dependent: :destroy

  enum :hotel_type, {
    hotel: "hotel",
    conventional: "conventional",
    hostal: "hostal",
    glamping: "glamping",
    ecohotel: "ecohotel"
  }

  validates :hotel_type, presence: { message: "Debe seleccionar el tipo de hospedaje" }
  validates :stars, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5, message: "La calificación debe estar entre 0 y 5 estrellas" }, allow_nil: true
  validates :total_rooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :available_rooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :max_guests, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true

  validate :validate_rooms_limit

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
  accepts_nested_attributes_for :rooms, allow_destroy: true

  private

  def validate_rooms_limit
    if rooms.reject(&:marked_for_destruction?).length > 10
      errors.add(:rooms, "Un hotel puede tener máximo 10 tipos de habitaciones.")
    end
  end
end
