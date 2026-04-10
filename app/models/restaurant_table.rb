class RestaurantTable < ApplicationRecord
  belongs_to :restaurant

  TABLE_TYPES = %w[standard vip outdoor bar private_room].freeze

  validates :name, presence: { message: "El nombre de la mesa es obligatorio" }
  validates :seats, presence: { message: "El número de asientos es obligatorio" },
                    numericality: { only_integer: true, greater_than: 0, message: "El número de asientos debe ser mayor a 0" }
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50, message: "La cantidad debe ser entre 1 y 50" }
  validates :table_type, inclusion: { in: TABLE_TYPES, message: "Tipo de mesa no válido" }, allow_blank: true
end
