class ExpireReservedTicketsJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    ticket = Ticket.find_by(id: ticket_id)
    return unless ticket
    return unless ticket.reservado?
    return unless ticket.reservation_expired?

    ticket.rechazar!
    Rails.logger.info("Ticket #{ticket.ticket_code} expirado por tiempo.")

    # Notificar al guest por email si no tiene cuenta registrada
    if ticket.user.nil? && ticket.guest_email.present?
      TicketMailer.ticket_rechazado_guest(ticket).deliver_later
    end
  end
end
