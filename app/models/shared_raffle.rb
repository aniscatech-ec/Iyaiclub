class SharedRaffle < ApplicationRecord
  has_many :shared_raffle_events,         dependent: :destroy
  has_many :events,                        through: :shared_raffle_events
  has_many :shared_raffle_participations,  dependent: :destroy
  has_many :participating_ticket_records,  through: :shared_raffle_participations, source: :ticket

  enum :status, { pendiente: 0, realizado: 1, cancelado: 2 }

  validates :name,  presence: true
  validates :prize, presence: true
  validates :winning_number, presence: true, if: :realizado?

  scope :pendiente, -> { where(status: :pendiente) }
  scope :completed, -> { where(status: :realizado) }

  # Participación de un ticket en este sorteo (nil si no participa)
  def participation_for(ticket)
    shared_raffle_participations.find_by(ticket: ticket)
  end

  # Número de participación de un ticket en este sorteo (nil si no participa)
  def participation_number_for(ticket)
    participation_for(ticket)&.participation_number
  end

  # Ticket ganador (busca por participation_number, no por raffle_number)
  def winner
    return nil unless winning_number.present? && realizado?
    shared_raffle_participations.find_by(participation_number: winning_number)&.ticket
  end

  # Realizar el sorteo: elige un participation_number al azar entre todos los inscritos
  def draw_winner!
    return false unless pendiente?

    available_numbers = shared_raffle_participations.pluck(:participation_number)
    return false if available_numbers.empty?

    self.winning_number = available_numbers.sample
    self.draw_date      = Time.current unless draw_date?
    self.status         = :realizado
    save
  end

  # Asignar un evento: registra los tickets activos actuales como participaciones.
  # Idempotente: si el evento ya está asignado, no duplica entradas.
  def assign_event!(event)
    shared_raffle_events.find_or_create_by!(event: event)
    enroll_tickets_for_event!(event)
  end

  def remove_event!(event)
    link = shared_raffle_events.find_by(event: event)
    return unless link

    # Quitar participaciones de tickets de ese evento
    ticket_ids = Ticket.where(event: event).participantes.pluck(:id)
    shared_raffle_participations.where(ticket_id: ticket_ids).destroy_all
    link.destroy
  end

  def participating_count
    shared_raffle_participations.count
  end

  # Participaciones de tickets de un evento específico
  def tickets_for_event(event)
    ticket_ids = Ticket.where(event: event).participantes.pluck(:id)
    shared_raffle_participations.where(ticket_id: ticket_ids).includes(:ticket)
  end

  # Enrolar todos los tickets activos de un evento que aún no tienen participación
  def enroll_tickets_for_event!(event)
    tickets = Ticket.where(event: event).participantes
    tickets.each { |ticket| enroll_ticket!(ticket) }
  end

  # Enrolar un ticket individual (llamado cuando se compra un nuevo ticket
  # en un evento que ya está asignado a este sorteo)
  def enroll_ticket!(ticket)
    return if shared_raffle_participations.exists?(ticket: ticket)

    number = generate_participation_number
    shared_raffle_participations.create!(ticket: ticket, participation_number: number)
  end

  private

  def generate_participation_number
    loop do
      num = rand(10_000..99_999)
      break num unless shared_raffle_participations.exists?(participation_number: num)
    end
  end
end
