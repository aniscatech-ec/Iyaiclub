class SharedRaffleParticipation < ApplicationRecord
  belongs_to :shared_raffle
  belongs_to :ticket

  validates :participation_number, presence: true,
            uniqueness: { scope: :shared_raffle_id }
  validates :ticket_id, uniqueness: { scope: :shared_raffle_id }
end
