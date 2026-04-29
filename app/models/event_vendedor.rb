class EventVendedor < ApplicationRecord
  self.table_name = 'event_vendedores'
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id, message: "ya está asignado a este evento" }
  validates :quota, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validate :user_must_be_vendedor

  scope :active, -> { where(active: true) }

  # Tickets acreditados (activos+usados) vendidos por este vendedor en este evento
  def tickets_sold
    Ticket.where(vendedor: user, event: event, status: [:activo, :usado]).count
  end

  # Tickets pendientes de acreditar
  def tickets_pending
    Ticket.where(vendedor: user, event: event, status: :reservado).count
  end

  # ¿Tiene cupo asignado?
  def has_quota?
    quota.present?
  end

  # ¿El cupo ya fue alcanzado?
  def quota_met?
    quota_met_at.present?
  end

  # ¿Cuántos tickets faltan para completar el cupo?
  def quota_remaining
    return nil unless has_quota?
    [quota - tickets_sold, 0].max
  end

  # Progreso 0..100 respecto al cupo (nil si no tiene cupo)
  def quota_progress_percent
    return nil unless has_quota?
    [(tickets_sold.to_f / quota * 100).round, 100].min
  end

  # Verificar y marcar cupo cumplido si corresponde (llamar tras acreditar tickets)
  def check_and_mark_quota!
    return unless has_quota?
    return if quota_met?
    if tickets_sold >= quota
      update_column(:quota_met_at, Time.current)
    end
  end

  private

  def user_must_be_vendedor
    errors.add(:user, "debe tener rol vendedor") unless user&.vendedor?
  end
end
