class User < ApplicationRecord
  include MembershipAccess

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  enum :role, administrador: 0, afiliado: 1, turista: 2, vendedor: 3
  has_many :establishments
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  belongs_to :country
  belongs_to :city

  has_many :user_points, dependent: :destroy
  has_many :redemptions, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :invoice_claims, dependent: :destroy
  has_many :custom_requests, dependent: :destroy
  has_many :assigned_custom_requests, class_name: "CustomRequest",
           foreign_key: :assigned_to_id, dependent: :nullify
  has_many :tickets, dependent: :destroy
  has_many :referrals_given,    class_name: "Referral", foreign_key: :referrer_id, dependent: :destroy
  has_many :referrals_received, class_name: "Referral", foreign_key: :referred_id, dependent: :nullify

  before_create :generate_referral_code

  has_one_attached :avatar
  has_one_attached :cover_photo

  # Documentos de identidad requeridos para afiliados
  has_one_attached :cedula_front  # Cédula anverso
  has_one_attached :cedula_back   # Cédula reverso
  has_one_attached :ruc_document  # RUC (foto o PDF)

  validate :identity_documents_required_for_afiliado, on: :create

  private_class_method def self.afiliado_doc_content_types
    %w[image/jpeg image/png image/webp application/pdf]
  end

  # Vendedor associations
  has_many :event_vendedores, class_name: 'EventVendedor', dependent: :destroy
  has_many :vendedor_events, through: :event_vendedores, source: :event
  has_many :handled_tickets, class_name: "Ticket", foreign_key: :vendedor_id, dependent: :nullify
  has_many :handled_subscriptions, class_name: "Subscription", foreign_key: :vendedor_id, dependent: :nullify

  def total_points
    user_points.sum(:points_earned) - redemptions.sum(:points_used)
  end

  has_many :bookings, dependent: :destroy

  def active_membership
    subscriptions.where(status: :activada).where("end_date >= ?", Date.current).order(end_date: :desc).first
  end

  # Callback para enviar correo de bienvenida y acreditar puntos al confirmar cuenta
  after_commit :on_account_confirmed, on: :update, if: :just_confirmed?

  private

  def identity_documents_required_for_afiliado
    return unless afiliado?
    errors.add(:cedula_front,  "Cédula (anverso) es obligatoria para afiliados") unless cedula_front.attached?
    errors.add(:cedula_back,   "Cédula (reverso) es obligatoria para afiliados") unless cedula_back.attached?
    errors.add(:ruc_document,  "Documento RUC es obligatorio para afiliados") unless ruc_document.attached?
  end

  def just_confirmed?
    saved_change_to_confirmed_at? && confirmed_at.present? && confirmed_at_before_last_save.nil?
  end

  def on_account_confirmed
    UserMailer.welcome_email(self).deliver_later
    grant_welcome_points
  end

  def grant_welcome_points
    PointsCalculator.grant(
      self,
      points: 500,
      source: :welcome,
      description: "Puntos de bienvenida por confirmar tu cuenta"
    )
  end

  def generate_referral_code
    return if referral_code.present?
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      unless User.exists?(referral_code: code)
        self.referral_code = code
        break
      end
    end
  end

end
