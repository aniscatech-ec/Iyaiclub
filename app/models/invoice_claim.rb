class InvoiceClaim < ApplicationRecord
  belongs_to :user
  belongs_to :establishment, optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true

  has_one_attached :invoice_file

  enum :status, {
    pendiente:  0,
    aprobada:   1,
    rechazada:  2
  }

  validates :amount,      presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :invoice_file, presence: true, on: :create

  scope :recent,    -> { order(created_at: :desc) }
  scope :by_status, ->(s) { where(status: s) }

  STATUS_BADGES = {
    "pendiente" => "warning",
    "aprobada"  => "success",
    "rechazada" => "danger"
  }.freeze

  STATUS_LABELS = {
    "pendiente" => "Pendiente",
    "aprobada"  => "Aprobada",
    "rechazada" => "Rechazada"
  }.freeze

  def status_badge
    STATUS_BADGES[status] || "secondary"
  end

  def status_label
    STATUS_LABELS[status] || status.humanize
  end

  def approve!(admin:, points:, notes: nil)
    ActiveRecord::Base.transaction do
      update!(
        status:         :aprobada,
        points_granted: points,
        admin_notes:    notes,
        reviewed_by:    admin,
        reviewed_at:    Time.current
      )
      PointsCalculator.grant(
        user,
        points: points,
        source: :invoice,
        establishment: establishment,
        description: "Puntos por factura aprobada ##{invoice_number.presence || id}"
      ).tap do |result|
        raise ActiveRecord::Rollback unless result[:success]
      end
    end
  end

  def reject!(admin:, notes: nil)
    update!(
      status:      :rechazada,
      admin_notes: notes,
      reviewed_by: admin,
      reviewed_at: Time.current
    )
  end
end
