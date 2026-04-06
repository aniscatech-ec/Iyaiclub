class TemporaryLodging < ApplicationRecord
  belongs_to :establishment

  LODGING_TYPES = %w[casa departamento quinta habitacion].freeze

  validates :lodging_type, presence: { message: "Debe seleccionar un tipo de alojamiento" },
                           inclusion: { in: LODGING_TYPES, message: "Tipo de alojamiento no valido" }
  validates :max_guests, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :total_rooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :total_bathrooms, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true

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
