class Experience < ApplicationRecord
  belongs_to :establishment
  belongs_to :getaway, optional: true
  has_many :bookings, as: :bookable, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :establishment, presence: true
end
