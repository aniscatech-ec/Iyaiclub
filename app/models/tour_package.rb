class TourPackage < ApplicationRecord
  belongs_to :travel_agency
  has_one_attached :cover_photo

  PACKAGE_TYPES = %w[aventura cultural relax naturaleza gastronomico familiar religioso fotografico].freeze
  DIFFICULTIES   = %w[facil moderado exigente].freeze
  SEASONS        = ["Todo el año", "Temporada alta", "Temporada baja", "Verano", "Invierno"].freeze

  validates :name,         presence: { message: "El nombre del paquete es obligatorio" }
  validates :package_type, inclusion: { in: PACKAGE_TYPES, message: "Tipo de paquete no válido" }, allow_blank: true
  validates :difficulty,   inclusion: { in: DIFFICULTIES,  message: "Dificultad no válida" },   allow_blank: true
  validates :price,        numericality: { greater_than_or_equal_to: 0, message: "El precio debe ser positivo" }, allow_nil: true
  validates :member_price, numericality: { greater_than_or_equal_to: 0, message: "El precio para miembros debe ser positivo" }, allow_nil: true
  validates :days,         numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :nights,       numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_group,    numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_group,    numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate  :max_group_gte_min_group
  validate  :packages_limit

  scope :active, -> { where(active: true) }

  def includes_list
    return [] if includes.blank?
    includes.split("\n").map(&:strip).reject(&:blank?)
  end

  def excludes_list
    return [] if excludes.blank?
    excludes.split("\n").map(&:strip).reject(&:blank?)
  end

  def duration_label
    parts = []
    parts << "#{days} #{days == 1 ? 'día' : 'días'}" if days.present?
    parts << "#{nights} #{nights == 1 ? 'noche' : 'noches'}" if nights.present? && nights > 0
    parts.join(" / ")
  end

  private

  def max_group_gte_min_group
    return unless min_group.present? && max_group.present?
    if max_group < min_group
      errors.add(:max_group, "no puede ser menor que el mínimo de personas")
    end
  end

  def packages_limit
    return unless travel_agency.present? && new_record?
    if travel_agency.tour_packages.count >= 5
      errors.add(:base, "Una agencia puede tener máximo 5 paquetes turísticos")
    end
  end
end
