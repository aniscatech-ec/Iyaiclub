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

  has_many :experiences, dependent: :destroy
  accepts_nested_attributes_for :experiences, allow_destroy: true, reject_if: :all_blank

  validates :subcategory, presence: true
  validates :entry_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :apply_free_entry
  before_validation :assign_establishment_to_experiences

  private

  def assign_establishment_to_experiences
    experiences.each do |exp|
      exp.establishment_id ||= establishment_id
    end
  end

  def apply_free_entry
    return unless free_entry?
    self.entry_price = 0
    establishment&.legal_info&.skip_validations = true if establishment&.legal_info
  end
end
