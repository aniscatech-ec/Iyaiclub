class TemporaryLodging < ApplicationRecord
  belongs_to :establishment

  LODGING_TYPES = %w[casa departamento quinta habitacion].freeze

  validates :lodging_type, presence: { message: "Debe seleccionar un tipo de alojamiento" },
                           inclusion: { in: LODGING_TYPES, message: "Tipo de alojamiento no valido" }

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
