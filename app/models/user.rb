class User < ApplicationRecord
  include MembershipAccess

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, administrador: 0, afiliado: 1, turista: 2
  has_many :establishments
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  belongs_to :country
  belongs_to :city

  has_many :user_points, dependent: :destroy
  has_many :redemptions, dependent: :destroy
  has_many :visits, dependent: :destroy

  def total_points
    user_points.sum(:points_earned) - redemptions.sum(:points_used)
  end

  def bookings
    Booking.where(guest_email: email)
  end

  def active_membership
    subscriptions.where(status: :activada).where("end_date >= ?", Date.current).order(end_date: :desc).first
  end
end
