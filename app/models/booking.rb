class Booking < ApplicationRecord
  belongs_to :bookable, polymorphic: true
  belongs_to :unit, -> { where(bookings: { bookable_type: 'Unit' }) }, foreign_key: 'bookable_id', optional: true
  belongs_to :user, optional: true

  alias_attribute :guests, :guest_count
  alias_attribute :date, :start_date

  enum :status, {
    pendiente: "pendiente",
    confirmado: "confirmado",
    rechazado: "rechazado",
    cancelado: "cancelado"
  }

  validates :start_date, :guest_count, presence: true
  validates :guest_name, :guest_email, :end_date, presence: true, if: -> { bookable_type == 'Unit' }
  validate :end_after_start
  validate :bookable_available

  def establishment
    bookable&.establishment
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

  def bookable_available
    return unless bookable_type == 'Unit'
    return if bookable.blank? || start_date.blank? || end_date.blank?
    unless bookable.available_between?(start_date, end_date)
      errors.add(:base, "La unidad no está disponible en las fechas seleccionadas")
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
