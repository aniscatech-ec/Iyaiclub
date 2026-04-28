class SharedRaffleEvent < ApplicationRecord
  belongs_to :shared_raffle
  belongs_to :event

  validates :event_id, uniqueness: { scope: :shared_raffle_id,
                                     message: "ya está asignado a este sorteo" }
end
