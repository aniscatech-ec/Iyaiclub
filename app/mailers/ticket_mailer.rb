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

  def ticket_confirmation(ticket)
    @ticket = ticket

    mail(
      to: ticket.guest_email,
      subject: "🎟️ Tu ticket de entrada - #{@ticket.ticket_code}"
    )
  end
end
