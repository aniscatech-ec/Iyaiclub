class Booking < ApplicationRecord
  belongs_to :bookable, polymorphic: true
  belongs_to :user, optional: true

  enum :status, {
    pendiente: "pendiente",
    confirmado: "confirmado",
    rechazado: "rechazado",
    cancelado: "cancelado"
  }

  validates :start_date, :guest_count, :guest_name, :guest_email, presence: true
  validates :end_date, presence: true, if: -> { !benefit_request? && bookable_type.in?(%w[Room Unit Lodging]) }
  validate :end_after_start
  validate :bookable_available

  scope :benefit_requests,   -> { where(benefit_request: true) }
  scope :pending_benefits,   -> { benefit_requests.where(status: "pendiente") }
  scope :confirmed_benefits, -> { benefit_requests.where(status: "confirmado") }

  BENEFIT_TYPES = { lodging: "lodging", pool: "pool" }.freeze

  def activar_beneficio!
    update!(status: "confirmado")
  end

  def benefit_label
    case benefit_type
    when "lodging" then "Alojamiento Gratuito"
    when "pool"    then "Piscina Gratuita"
    else "Beneficio Exclusivo"
    end
  end

  def establishment
    case bookable
    when Room
      bookable.hotel&.establishment
    when Hotel
      bookable.establishment
    else
      bookable&.establishment
    end
  end

  def total_nights
    return 0 if start_date.blank? || end_date.blank?
    (end_date - start_date).to_i
  end

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "debe ser posterior a la fecha de inicio") if end_date < start_date
  end

  def bookable_available
    return unless bookable_type == 'Unit'
    return if bookable.blank? || start_date.blank? || end_date.blank?
    unless bookable.available_between?(start_date, end_date)
      errors.add(:base, "La unidad no está disponible en las fechas seleccionadas")
    end
  end
end
