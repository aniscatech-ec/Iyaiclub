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
  has_many :custom_requests, dependent: :destroy
  has_many :assigned_custom_requests, class_name: "CustomRequest",
           foreign_key: :assigned_to_id, dependent: :nullify
  has_many :tickets, dependent: :destroy

  # Vendedor associations
  has_many :event_vendedores, class_name: 'EventVendedor', dependent: :destroy
  has_many :vendedor_events, through: :event_vendedores, source: :event
  has_many :handled_tickets, class_name: "Ticket", foreign_key: :vendedor_id, dependent: :nullify

  def total_points
    user_points.sum(:points_earned) - redemptions.sum(:points_used)
  end

  def bookings
    Booking.where(guest_email: email)
  end

  def active_membership
    subscriptions.where(status: :activada).where("end_date >= ?", Date.current).order(end_date: :desc).first
  end

  # Callback para enviar correo de bienvenida después de confirmar cuenta
  after_commit :send_welcome_email, on: :update, if: :just_confirmed?

  private

  def just_confirmed?
    saved_change_to_confirmed_at? && confirmed_at.present? && confirmed_at_before_last_save.nil?
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
