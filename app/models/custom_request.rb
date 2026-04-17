class CustomRequest < ApplicationRecord
  INTERESTS    = %w[gastronomia aventura relax cultura vida_nocturna].freeze
  PREFERENCES  = %w[hoteles restaurantes transporte actividades].freeze

  belongs_to :user
  belongs_to :assigned_to, class_name: "User", optional: true

  serialize :interests,   type: Array, coder: YAML
  serialize :preferences, type: Array, coder: YAML

  enum :experience_type, { economica: 0, media: 1, premium: 2, lujo: 3 }
  enum :status,          { pendiente: 0, en_proceso: 1, completado: 2, cancelado: 3 }

  validates :destination, :start_date, :end_date, :guests_count, :experience_type, presence: true
  validates :guests_count, numericality: { greater_than: 0 }
  validates :estimated_budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :end_date_after_start_date
  validate  :interests_allowed
  validate  :preferences_allowed

  scope :recent, -> { order(created_at: :desc) }

  def total_days
    return 0 if start_date.blank? || end_date.blank?
    (end_date - start_date).to_i
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "debe ser posterior a la fecha de inicio") if end_date < start_date
  end

  def interests_allowed
    return if interests.blank?
    invalid = Array(interests).reject { |i| INTERESTS.include?(i.to_s) }
    errors.add(:interests, "contiene valores no permitidos") if invalid.any?
  end

  def preferences_allowed
    return if preferences.blank?
    invalid = Array(preferences).reject { |p| PREFERENCES.include?(p.to_s) }
    errors.add(:preferences, "contiene valores no permitidos") if invalid.any?
  end
end
