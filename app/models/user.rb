class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, administrador: 0, afiliado: 1, turista: 2
  has_many :establishments
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_many :reservations, dependent: :destroy

  belongs_to :country
  belongs_to :city

end
