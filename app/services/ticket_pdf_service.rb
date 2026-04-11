class TicketPdfService
  def initialize(ticket)
    @ticket = ticket
  end

  def generate
    Prawn::Document.new(page_size: [400, 600], margin: 20) do |pdf|
      render_header(pdf)
      render_event_info(pdf)
      render_guest_info(pdf)
      render_qr_code(pdf)
      render_raffle_section(pdf)
      render_footer(pdf)
    end.render
  end

  private

  def render_header(pdf)
    pdf.font "Helvetica"
    pdf.fill_color "2E7D32"
    pdf.text "IYAICLUB", size: 28, style: :bold, align: :center
    pdf.fill_color "000000"
    pdf.move_down 5
    pdf.text "TICKET DE ENTRADA", size: 14, style: :bold, align: :center, color: "555555"
    pdf.move_down 5
    pdf.stroke_horizontal_rule
    pdf.move_down 15
  end

  def render_event_info(pdf)
    pdf.fill_color "1B5E20"
    pdf.text @ticket.event_name, size: 20, style: :bold, align: :center
    pdf.fill_color "000000"
    pdf.move_down 8

    if @ticket.event_date.present?
      pdf.text "Fecha: #{@ticket.event_date.strftime('%d/%m/%Y')}", size: 11, align: :center
    end
    if @ticket.event_location.present?
      pdf.text "Lugar: #{@ticket.event_location}", size: 11, align: :center
    end
    pdf.move_down 12
    pdf.stroke_horizontal_rule
    pdf.move_down 12
  end

  def render_guest_info(pdf)
    pdf.text "Asistente: #{@ticket.guest_name}", size: 12, style: :bold
    pdf.text "Email: #{@ticket.guest_email}", size: 10, color: "555555" if @ticket.guest_email.present?
    pdf.move_down 10

    pdf.fill_color "F5F5F5"
    pdf.fill_rounded_rectangle [0, pdf.cursor], 360, 45, 5
    pdf.fill_color "000000"

    pdf.move_down 8
    pdf.indent(10) do
      pdf.text "Codigo: #{@ticket.ticket_code}", size: 14, style: :bold
      pdf.text "Precio: $#{'%.2f' % (@ticket.unit_price || 0)} USD", size: 10
    end
    pdf.move_down 15
  end

  def render_qr_code(pdf)
    qr_png = @ticket.qr_png_data
    pdf.image StringIO.new(qr_png), width: 150, position: :center
    pdf.move_down 10
  end

  def render_raffle_section(pdf)
    pdf.fill_color "FFF8E1"
    pdf.fill_rounded_rectangle [0, pdf.cursor], 360, 55, 5
    pdf.fill_color "000000"

    pdf.move_down 8
    pdf.text "NUMERO DE RIFA", size: 10, style: :bold, align: :center, color: "F57F17"
    pdf.text @ticket.raffle_number.to_s, size: 28, style: :bold, align: :center, color: "E65100"
    pdf.move_down 8
    pdf.text "Con este numero participas en el sorteo oficial del evento", size: 8, align: :center, color: "555555"
    pdf.move_down 10
  end

  def render_footer(pdf)
    pdf.stroke_horizontal_rule
    pdf.move_down 8
    pdf.text "Presenta este ticket (impreso o digital) en la entrada del evento.", size: 8, align: :center, color: "888888"
    pdf.text "www.iyaiclub.com", size: 8, align: :center, color: "2E7D32"
  end
end
