class Restaurant < ApplicationRecord
  belongs_to :establishment

  CUISINE_TYPES = %w[tipica rapida italiana espanola ecuatoriana asiatica].freeze
  CATEGORIES = %w[restaurante cafeteria].freeze

  validates :cuisine_type, presence: { message: "Debe seleccionar el tipo de cocina" },
                          inclusion: { in: CUISINE_TYPES, message: "Tipo de cocina no valido" }
  validates :category, presence: { message: "Debe seleccionar la categoria del restaurante" },
                       inclusion: { in: CATEGORIES, message: "Categoria no valida" }
  validates :total_tables, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :seats_per_table, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :available_tables, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true
  validates :total_capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "Debe ser un numero entero positivo" }, allow_nil: true

  has_many :menus, dependent: :destroy
  has_many :restaurant_tables, dependent: :destroy

  accepts_nested_attributes_for :menus, allow_destroy: true
  accepts_nested_attributes_for :restaurant_tables, allow_destroy: true

  validate :validate_menus_limit
  validate :validate_tables_limit

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

  private

  def validate_menus_limit
    if menus.reject(&:marked_for_destruction?).length > 5
      errors.add(:menus, "Un restaurante puede tener máximo 5 menús.")
    end
  end

  def validate_tables_limit
    if restaurant_tables.reject(&:marked_for_destruction?).length > 10
      errors.add(:restaurant_tables, "Un restaurante puede tener máximo 10 tipos de mesas.")
    end
  end
end
