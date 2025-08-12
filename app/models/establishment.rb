class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :establishment_amenities
  has_many :amenities, through: :establishment_amenities


  enum :category, hotel: 0, restaurante: 1

  validates :name, :description, :category, presence: true
end
