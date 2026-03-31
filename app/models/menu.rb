class Menu < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :menu_items, allow_destroy: true
end
