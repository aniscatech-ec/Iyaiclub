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

    @tickets.each do |t|
      pdf_data = TicketPdfService.new(t).generate
      attachments["ticket_#{t.ticket_code}.pdf"] = {
        mime_type: "application/pdf",
        content:   pdf_data
      }
    end

    mail(
      to: @tickets.first.guest_email,
      subject: "🎟️ Tu#{@tickets.size > 1 ? 's' : ''} ticket#{@tickets.size > 1 ? 's' : ''} para #{@event_name} - IyaiClub"
    )
  end

  # Acepta user nil para soportar guests (transferencia confirmada por vendedor).
  # tickets puede ser un array (compra múltiple) o un solo ticket.
  def ticket_acreditado(user, tickets)
    @tickets    = Array(tickets)
    @ticket     = @tickets.first
    @event_name = @ticket.event_name
    @name       = user&.name || @ticket.guest_name.to_s.split("·").first.strip
    recipient   = user&.email || @ticket.guest_email

    # Adjuntar un PDF por ticket
    @tickets.each do |t|
      pdf_data = TicketPdfService.new(t).generate
      attachments["ticket_#{t.ticket_code}.pdf"] = {
        mime_type: "application/pdf",
        content:   pdf_data
      }
    end

    mail(to: recipient, subject: "✅ Ticket#{@tickets.size > 1 ? 's' : ''} confirmado#{@tickets.size > 1 ? 's' : ''} para #{@event_name} - IyaiClub")
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
