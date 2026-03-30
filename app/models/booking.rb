class Booking < ApplicationRecord
  belongs_to :unit

  enum :status, {
    pendiente: "pendiente",
    confirmado: "confirmado",
    rechazado: "rechazado",
    cancelado: "cancelado"
  }

  validates :guest_name, :guest_email, :guest_count, :start_date, :end_date, presence: true
  validate :end_after_start
  validate :unit_available

  def establishment
    unit&.establishment
  end

  def total_nights
    return 0 if start_date.blank? || end_date.blank?
    (end_date - start_date).to_i
  end

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end

  def unit_available
    return if unit.blank? || start_date.blank? || end_date.blank?
    unless unit.available_between?(start_date, end_date)
      errors.add(:base, "La unidad no está disponible en las fechas seleccionadas")
    end
  end
end
