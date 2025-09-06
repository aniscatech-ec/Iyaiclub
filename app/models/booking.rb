class Booking < ApplicationRecord
  belongs_to :unit

  validates :guest_name, :guest_email, :guest_count, :start_date, :end_date, presence: true
  validate :end_after_start

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end
end
