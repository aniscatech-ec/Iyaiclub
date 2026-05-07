class Event < ApplicationRecord
  has_many :tickets, dependent: :nullify
  has_many :raffles, dependent: :destroy
  has_many :shared_raffle_events, dependent: :destroy
  has_many :shared_raffles, through: :shared_raffle_events
  has_many :event_vendedores, class_name: 'EventVendedor', dependent: :destroy
  has_many :vendedores, through: :event_vendedores, source: :user
  has_many :event_stands, dependent: :destroy
  has_many :stands, through: :event_stands
  has_one_attached :image

  enum :status, { borrador: 0, publicado: 1, cancelado: 2, finalizado: 3 }

  validates :name, presence: true
  validates :member_price,     numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :non_member_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stand_price,      numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_tickets,    numericality: { greater_than: 0 }, allow_nil: true
  validates :available_tickets, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :combo_quantity, numericality: { greater_than: 1, only_integer: true }, allow_nil: true
  validates :combo_discount, numericality: { greater_than: 0 }, allow_nil: true
  validate :combo_fields_present_together

  validate :available_tickets_cannot_exceed_total

  scope :published, -> { where(status: :publicado) }
  scope :upcoming, -> { where("event_date >= ?", Date.current) }
  scope :past, -> { where("event_date < ?", Date.current) }

  # Precio unitario base según contexto.
  # Acepta vendedor_id (user) o stand_id (stand autónomo); stand_id tiene precedencia.
  def price_for(user, quantity = 1, vendedor_id: nil, stand_id: nil)
    if stand_id.present?
      ev = event_vendedores.find_by(stand_id: stand_id, vendor_type: :stand_autonomo)
      return (stand_price || ticket_price || 0).to_f if ev.present?
    end

    if vendedor_id.present?
      ev = event_vendedores.find_by(user_id: vendedor_id)
      return (stand_price || ticket_price || 0).to_f if ev&.vendor_type_stand?
    end

    if user.present?
      (member_price || ticket_price || 0).to_f
    else
      (non_member_price || ticket_price || 0).to_f
    end
  end

  # Total a cobrar por N tickets, aplicando el descuento combo si aplica.
  # El combo no aplica para tickets de stand.
  def total_price_for(user, quantity, vendedor_id: nil, stand_id: nil)
    quantity = quantity.to_i
    subtotal = price_for(user, quantity, vendedor_id: vendedor_id, stand_id: stand_id) * quantity

    # Sin combo para stands
    if stand_id.present?
      ev = event_vendedores.find_by(stand_id: stand_id, vendor_type: :stand_autonomo)
      return subtotal if ev.present?
    end

    if vendedor_id.present?
      ev = event_vendedores.find_by(user_id: vendedor_id)
      return subtotal if ev&.vendor_type_stand?
    end

    if combo_active? && user.present? && quantity >= combo_quantity
      complete_lots = quantity / combo_quantity
      [subtotal - combo_discount.to_f * complete_lots, 0].max
    else
      subtotal
    end
  end

  # EventVendedor de stand autónomo para este evento
  def stand_autonomo_vendedor(stand)
    event_vendedores.find_by(stand: stand, vendor_type: :stand_autonomo)
  end

  # true si el precio de stand está configurado
  def stand_price?
    stand_price.present? && stand_price > 0
  end

  # true si el combo está configurado y activo
  def combo_active?
    combo_quantity.present? && combo_discount.present? && combo_discount > 0
  end

  # Evento completamente gratuito si ambos precios son 0 (o nil)
  def free?
    member_price.to_f == 0 && non_member_price.to_f == 0
  end

  def sold_out?
    available_tickets == 0
  end

  def active_vendedores
    vendedores.merge(EventVendedor.active)
  end

  def upcoming?
    event_date.present? && event_date >= Date.current
  end

  def past?
    event_date.present? && event_date < Date.current
  end

  private

  def combo_fields_present_together
    if combo_quantity.present? ^ combo_discount.present?
      errors.add(:base, "El precio combo requiere configurar tanto la cantidad mínima como el descuento")
    end
  end

  def available_tickets_cannot_exceed_total
    if total_tickets.present? && available_tickets.present?
      if available_tickets > total_tickets
        errors.add(:available_tickets, "no puede ser mayor al total de tickets")
      end
    end
  end
end
