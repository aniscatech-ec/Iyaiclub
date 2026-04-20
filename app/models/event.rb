class Event < ApplicationRecord
  has_many :tickets, dependent: :nullify
  has_many :raffles, dependent: :destroy
  has_many :event_vendedores, class_name: 'EventVendedor', dependent: :destroy
  has_many :vendedores, through: :event_vendedores, source: :user
  has_one_attached :image

  enum :status, { borrador: 0, publicado: 1, cancelado: 2, finalizado: 3 }

  validates :name, presence: true
  validates :member_price,     numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :non_member_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_tickets,    numericality: { greater_than: 0 }, allow_nil: true
  validates :available_tickets, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :available_tickets_cannot_exceed_total

  scope :published, -> { where(status: :publicado) }
  scope :upcoming, -> { where("event_date >= ?", Date.current) }
  scope :past, -> { where("event_date < ?", Date.current) }

  # Retorna el precio correcto según si el usuario está autenticado (afiliado/turista)
  # o es un visitante no loggeado. Recibe el user object o nil.
  def price_for(user)
    if user.present?
      (member_price || ticket_price || 0).to_f
    else
      (non_member_price || ticket_price || 0).to_f
    end
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

  def available_tickets_cannot_exceed_total
    if total_tickets.present? && available_tickets.present?
      if available_tickets > total_tickets
        errors.add(:available_tickets, "no puede ser mayor al total de tickets")
      end
    end
  end
end
