class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  belongs_to :payphone_transaction, optional: true

  enum :status, { activo: 0, usado: 1, cancelado: 2 }

  validates :ticket_code, presence: true, uniqueness: true
  validates :raffle_number, presence: true, uniqueness: true
  validates :guest_name, :event_name, presence: true

  before_validation :generate_ticket_code, on: :create
  before_validation :generate_raffle_number, on: :create
  after_validation :generate_qr_data, on: :create

  scope :for_event, ->(name) { where(event_name: name) if name.present? }
  scope :participantes, -> { where(status: :activo) }

  def mark_as_used!
    update!(status: :usado, used_at: Time.current)
  end

  def qr_svg(module_size: 4)
    qrcode = RQRCode::QRCode.new(qr_data)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: module_size,
      standalone: true,
      use_path: true
    )
  end

  def qr_png_data
    qrcode = RQRCode::QRCode.new(qr_data)
    qrcode.as_png(size: 300, border_modules: 2).to_s
  end

  private

  def generate_ticket_code
    return if ticket_code.present?

    last_number = self.class.maximum(:id).to_i
    self.ticket_code = "EXP-#{format('%06d', last_number + 1)}"

    # Asegurar unicidad
    while self.class.exists?(ticket_code: ticket_code)
      last_number += 1
      self.ticket_code = "EXP-#{format('%06d', last_number + 1)}"
    end
  end

  def generate_raffle_number
    return if raffle_number.present?

    loop do
      self.raffle_number = rand(10_000..99_999)
      break unless self.class.exists?(raffle_number: raffle_number)
    end
  end

  def generate_qr_data
    return if qr_data.present?

    self.qr_data = {
      ticket: ticket_code,
      event: event_name,
      guest: guest_name,
      raffle: raffle_number
    }.to_json
  end
end
