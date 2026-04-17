class RoomBed < ApplicationRecord
  belongs_to :room

  BED_TYPES = %w[1_plaza plaza_y_media doble queen king].freeze

  validates :bed_type, presence: { message: "Debe seleccionar un tipo de cama" },
                       inclusion: { in: BED_TYPES, message: "Tipo de cama no válido" }
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20, message: "La cantidad debe ser entre 1 y 20" }
end
