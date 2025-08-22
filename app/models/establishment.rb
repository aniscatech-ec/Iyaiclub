class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  # has_many :establishment_amenities #da error por elimincacion
  # has_many :amenities, through: :establishment_amenities #error por eliminacion
  has_many :establishment_amenities, dependent: :destroy
  has_many :amenities, through: :establishment_amenities
  # has_many :subscriptions, as: :suscribable, dependent: :destroy

  enum :category, hotel: 0, restaurante: 1

  validates :name, :description, :category, presence: true
end
