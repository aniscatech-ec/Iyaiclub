class Transport < ApplicationRecord
  belongs_to :establishment

  TRANSPORT_TYPES = %w[terrestre acuatico].freeze

  TERRESTRIAL_SUBCATEGORIES = %w[buses busetas transporte_mixto buses_turisticos taxis rentadoras].freeze
  AQUATIC_SUBCATEGORIES = %w[botes yates paseos_en_bote cruceros].freeze
  ALL_SUBCATEGORIES = (TERRESTRIAL_SUBCATEGORIES + AQUATIC_SUBCATEGORIES).freeze

  has_many :vehicles, dependent: :destroy
  accepts_nested_attributes_for :vehicles, allow_destroy: true

  accepts_nested_attributes_for :establishment

  validates :transport_type, inclusion: { in: TRANSPORT_TYPES }
  validates :subcategory, inclusion: { in: ALL_SUBCATEGORIES }
  validate :subcategory_matches_type
  validate :validate_vehicles_limit

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

  def terrestrial?
    transport_type == "terrestre"
  end

  def aquatic?
    transport_type == "acuatico"
  end

  def rentadora?
    subcategory == "rentadoras"
  end

  def subcategories_for_type
    terrestrial? ? TERRESTRIAL_SUBCATEGORIES : AQUATIC_SUBCATEGORIES
  end

  private

  def subcategory_matches_type
    return if transport_type.blank? || subcategory.blank?

    valid_subs = transport_type == "terrestre" ? TERRESTRIAL_SUBCATEGORIES : AQUATIC_SUBCATEGORIES
    unless valid_subs.include?(subcategory)
      errors.add(:subcategory, "no es válida para el tipo de transporte #{transport_type}")
    end
  end

  def validate_vehicles_limit
    if vehicles.reject(&:marked_for_destruction?).length > 5
      errors.add(:vehicles, "Un transporte puede tener máximo 5 vehículos.")
    end
  end
end
