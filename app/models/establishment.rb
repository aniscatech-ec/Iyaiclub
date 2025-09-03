class Establishment < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  # has_many :establishment_amenities #da error por elimincacion
  # has_many :amenities, through: :establishment_amenities #error por eliminacion
  has_many :establishment_amenities, dependent: :destroy
  has_many :amenities, through: :establishment_amenities
  # has_many :subscriptions, as: :suscribable, dependent: :destroy

  enum :category, hotel: 0, restaurante: 1

  # validates :name, :description, :category, presence: true
  belongs_to :city, optional: true
  belongs_to :province, optional: true


  has_one :legal_info, dependent: :destroy
  has_one :verification, dependent: :destroy

  has_many :units, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :galleries, dependent: :destroy

  accepts_nested_attributes_for :legal_info
  accepts_nested_attributes_for :verification
  accepts_nested_attributes_for :units
  accepts_nested_attributes_for :payment_methods
  accepts_nested_attributes_for :galleries
  has_one :pricing_policy, dependent: :destroy
  accepts_nested_attributes_for :pricing_policy
end
