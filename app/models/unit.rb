class Unit < ApplicationRecord
  belongs_to :establishment
  # store :seasonal_prices, accessors: [:high, :low], coder: JSON
  has_many :unit_prices, dependent: :destroy
  has_many :unit_availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy
  # Guardar un JSON de configuración de camas
  # serialize :bed_configuration

  accepts_nested_attributes_for :unit_prices, allow_destroy: true
  accepts_nested_attributes_for :unit_availabilities, allow_destroy: true

  # after_create :generate_initial_availability

  # Método de disponibilidad por rango
  def available_between?(start_date, end_date)
    bookings.where(status: "confirmado")
            .where("start_date <= ? AND end_date >= ?", end_date, start_date)
            .none?
  end

  private

  def generate_initial_availability
    (Date.today..(Date.today + 30)).each do |date|
      unit_availabilities.create!(date: date, available: true)
    end
  end
end
