class Lodging < ApplicationRecord
  belongs_to :establishment

  enum :lodging_type, {
    hotel: 0,
    hostal: 1,
    cabana: 2,
    lodge: 3,
    departamento: 4
  }

  validates :lodging_type, presence: true
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }
end
