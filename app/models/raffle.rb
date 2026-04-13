class Raffle < ApplicationRecord
  belongs_to :event
  has_many :tickets, through: :event

  enum :status, { pendiente: 0, realizado: 1, cancelado: 2 }

  validates :prize, presence: true
  validates :winning_number, presence: true, uniqueness: { scope: :event_id }, if: :realizado?

  scope :pending, -> { where(status: :pendiente) }
  scope :completed, -> { where(status: :realizado) }

  def winner
    return nil unless winning_number.present? && realizado?
    tickets.find_by(raffle_number: winning_number)
  end

  def draw_winner!
    return false unless pendiente?
    return false if event.tickets.participantes.empty?

    available_numbers = event.tickets.participantes.pluck(:raffle_number)
    self.winning_number = available_numbers.sample
    self.draw_date = Time.current
    self.status = :realizado
    
    save
  end
end
