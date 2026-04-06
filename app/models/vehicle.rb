class Vehicle < ApplicationRecord
  belongs_to :transport
  has_one_attached :photo

  validates :name, presence: true
  validates :price_per_day, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
