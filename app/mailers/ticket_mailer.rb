class TicketMailer < ApplicationMailer
  default from: 'info@iyaiclub.com'

  def ticket_purchased(user, tickets)
    @user = user
    @tickets = tickets
    @event_name = tickets.first.event_name
    @total_amount = tickets.sum(&:total_price)

    mail(
      to: @user.email,
      subject: "🎟️ Tu ticket para #{@event_name} - IyaiClub"
    )
  end

  # Email de tickets para guest tras pago con tarjeta (PayPhone)
  def ticket_confirmation_guest(tickets)
    @tickets = Array(tickets)
    @event_name = @tickets.first.event_name
    @total_amount = @tickets.sum(&:total_price)
    @guest_name = @tickets.first.guest_name.to_s.split("·").first.strip
    @ticket_url = Rails.application.routes.url_helpers
                       .guests_ticket_url(@tickets.first.ticket_code, host: default_url_options[:host])

    mail(
      to: @tickets.first.guest_email,
      subject: "🎟️ Tu ticket para #{@event_name} - IyaiClub"
    )
  end

  # Acepta user nil para soportar guests (transferencia confirmada por vendedor)
  def ticket_acreditado(user, ticket)
    @ticket     = ticket
    @event_name = ticket.event_name
    @name       = user&.name || ticket.guest_name.to_s.split("·").first.strip
    recipient   = user&.email || ticket.guest_email

    helpers = Rails.application.routes.url_helpers
    host    = default_url_options[:host]

    @ticket_url = if user.present?
                    helpers.turista_ticket_url(ticket, host: host)
                  else
                    helpers.guests_ticket_url(ticket.ticket_code, host: host)
                  end

    mail(to: recipient, subject: "✅ Ticket confirmado para #{@event_name} - IyaiClub")
  end

  # Notificación de rechazo solo para guests (turistas loggeados ven el polling en tiempo real)
  def ticket_rechazado_guest(ticket)
    @ticket     = ticket
    @event_name = ticket.event_name
    @guest_name = ticket.guest_name.to_s.split("·").first.strip
    @event_url  = Rails.application.routes.url_helpers
                       .event_url(ticket.event_id, host: default_url_options[:host])

    mail(
      to: ticket.guest_email,
      subject: "Reserva de ticket rechazada - #{@event_name} - IyaiClub"
    )
  end
end
