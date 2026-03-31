class Restaurant < ApplicationRecord
  belongs_to :establishment

  CUISINE_TYPES = %w[tipica rapida italiana espanola ecuatoriana asiatica].freeze
  CATEGORIES = %w[restaurante cafeteria].freeze

  validates :cuisine_type, inclusion: { in: CUISINE_TYPES }, allow_blank: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  has_many :menus, dependent: :destroy
  accepts_nested_attributes_for :menus, allow_destroy: true

  validate :validate_menus_limit

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
end
