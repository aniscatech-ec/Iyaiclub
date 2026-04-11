class Getaway < ApplicationRecord
  belongs_to :establishment
  has_many :bookings, as: :bookable, dependent: :destroy
  accepts_nested_attributes_for :establishment

  enum :subcategory, {
    museo: 0,
    parque_mirador: 1,
    piscina: 2,
    balneario: 3,
    centro_recreacional: 4,
    parque_extremo: 5,
    senderismo: 6,
    camping: 7
  }

  validates :subcategory, presence: true
  validates :entry_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
