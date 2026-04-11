class Booking < ApplicationRecord
  belongs_to :unit, optional: true
  belongs_to :room, optional: true

  enum :status, {
    pendiente: "pendiente",
    confirmado: "confirmado",
    rechazado: "rechazado",
    cancelado: "cancelado"
  }

  before_validation :calculate_total_price

  validates :guest_name, :guest_email, :guest_count, :start_date, :end_date, presence: true
  validate :end_after_start
  validate :unit_available

  def establishment
    room&.hotel&.establishment || unit&.establishment
  end

  def total_nights
    return 0 if start_date.blank? || end_date.blank?
    (end_date - start_date).to_i
  end

  private

  def calculate_total_price
    return if start_date.blank? || end_date.blank?

    nights = (end_date - start_date).to_i
    price = room&.price_per_night || unit&.base_price || 0
    self.total_price = nights * price
  end

  def end_after_start
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end

  def unit_available
    return if (unit.blank? && room.blank?) || start_date.blank? || end_date.blank?
    
    if unit.present?
      unless unit.available_between?(start_date, end_date)
        errors.add(:base, "La unidad no está disponible en las fechas seleccionadas")
      end
    elsif room.present?
      unless room_available_between?(start_date, end_date)
        errors.add(:base, "La habitación no está disponible en las fechas seleccionadas")
      end
    end
  end

  def room_available_between?(start_date, end_date)
    # Verificar si hay bookings que se solapen para esta room
    overlapping_bookings = room.bookings.where.not(status: ['cancelado', 'rechazado'])
                               .where('(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?)', 
                                      end_date, start_date, start_date, end_date)
    overlapping_bookings.count < room.quantity
  end
end
