class TicketGeneratorService
  def initialize(user, payphone_transaction: nil, ticket_params: {})
    @user = user
    @payphone_transaction = payphone_transaction
    @params = ticket_params
  end

  def call
    return { success: false, error: "Usuario inválido" } unless @user
    return { success: false, error: "Datos del evento requeridos" } if @params[:event_name].blank?

    quantity = [@params[:quantity].to_i, 1].max
    unit_price = @params[:unit_price].to_f
    total_price = unit_price * quantity

    tickets = []
    quantity.times do
      ticket = Ticket.create!(
        user: @user,
        payphone_transaction: @payphone_transaction,
        guest_name: @params[:guest_name] || @user.name,
        guest_email: @params[:guest_email] || @user.email,
        guest_phone: @params[:guest_phone] || @user.phone,
        event_name: @params[:event_name],
        event_date: @params[:event_date],
        event_location: @params[:event_location],
        unit_price: unit_price,
        total_price: total_price
      )
      tickets << ticket
    end

    # Enviar email con los tickets
    TicketMailer.ticket_purchased(@user, tickets).deliver_later

    { success: true, tickets: tickets }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  end
end
