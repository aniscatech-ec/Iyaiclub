class EventVendedor < ApplicationRecord
  self.table_name = 'event_vendedores'
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id, message: "ya está asignado a este evento" }
  validate :user_must_be_vendedor

  scope :active, -> { where(active: true) }

  private

  def user_must_be_vendedor
    errors.add(:user, "debe tener rol vendedor") unless user&.vendedor?
  end
end
