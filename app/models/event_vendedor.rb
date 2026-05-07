class EventVendedor < ApplicationRecord
  self.table_name = 'event_vendedores'

  belongs_to :event
  belongs_to :user, optional: true
  belongs_to :stand, optional: true

  # normal      — vendedor humano sin stand
  # stand       — vendedor humano asignado a un stand específico
  # stand_autonomo — el stand actúa solo; el propietario (owner_user) es quien opera
  enum :vendor_type, { normal: 0, stand: 1, stand_autonomo: 2 }, prefix: true

  validates :quota, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  # Un mismo user solo puede aparecer una vez por evento (nil ignorado)
  validates :user_id, uniqueness: { scope: :event_id,
                                    message: "ya está asignado a este evento" },
                      allow_nil: true

  # Un stand autónomo solo puede aparecer una vez por evento
  validates :stand_id, uniqueness: { scope: :event_id,
                                     message: "ya está asignado a este evento como stand autónomo" },
                       if: :vendor_type_stand_autonomo?

  validate :user_must_be_vendedor
  validate :stand_required_for_stand_types
  validate :stand_must_belong_to_event
  validate :stand_autonomo_requires_owner

  scope :active,           -> { where(active: true) }
  scope :stand_type,       -> { where(vendor_type: :stand) }
  scope :normal_type,      -> { where(vendor_type: :normal) }
  scope :stand_autonomo,   -> { where(vendor_type: :stand_autonomo) }

  # ── Identidad ─────────────────────────────────────────────────────────────

  # Quién opera este slot de venta (user humano o propietario del stand)
  def seller
    user || stand&.owner_user
  end

  def display_name
    if vendor_type_stand_autonomo?
      stand.name
    else
      user&.name
    end
  end

  # ── Conteo de tickets ─────────────────────────────────────────────────────

  def tickets_sold
    if vendor_type_stand_autonomo?
      Ticket.where(stand_id: stand_id, event: event, status: [:activo, :usado]).count
    else
      Ticket.where(vendedor: user, event: event, status: [:activo, :usado]).count
    end
  end

  def tickets_pending
    if vendor_type_stand_autonomo?
      Ticket.where(stand_id: stand_id, event: event, status: :reservado).count
    else
      Ticket.where(vendedor: user, event: event, status: :reservado).count
    end
  end

  # ── Cuota ─────────────────────────────────────────────────────────────────

  def has_quota?
    quota.present?
  end

  def quota_met?
    quota_met_at.present?
  end

  def quota_remaining
    return nil unless has_quota?
    [quota - tickets_sold, 0].max
  end

  def quota_progress_percent
    return nil unless has_quota?
    [(tickets_sold.to_f / quota * 100).round, 100].min
  end

  def check_and_mark_quota!
    return unless has_quota?
    return if quota_met?
    update_column(:quota_met_at, Time.current) if tickets_sold >= quota
  end

  private

  def user_must_be_vendedor
    return if vendor_type_stand_autonomo?
    return if user.nil?
    errors.add(:user, "debe tener rol vendedor") unless user.vendedor?
  end

  def stand_required_for_stand_types
    if (vendor_type_stand? || vendor_type_stand_autonomo?) && stand_id.blank?
      errors.add(:stand, "debe seleccionarse para vendedores de tipo stand")
    end
  end

  def stand_must_belong_to_event
    return unless stand.present? && event.present?
    return if vendor_type_stand_autonomo?  # el EventStand que disparó esto aún no está committed
    unless event.stands.include?(stand)
      errors.add(:stand, "no está asignado a este evento")
    end
  end

  def stand_autonomo_requires_owner
    return unless vendor_type_stand_autonomo?
    errors.add(:stand, "debe tener un propietario asignado para operar de forma autónoma") unless stand&.owner_user.present?
  end
end
