class Promotion < ApplicationRecord
  belongs_to :establishment

  validates :title, presence: true
  validates :discount_percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "debe ser posterior o igual a la fecha de inicio")
    end
  end
end
