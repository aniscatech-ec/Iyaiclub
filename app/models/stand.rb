class Stand < ApplicationRecord
  has_many :event_stands, dependent: :destroy
  has_many :events, through: :event_stands
  has_many :event_vendedores, dependent: :nullify

  validates :name,       presence: true
  validates :stand_code, presence: true, uniqueness: true

  before_validation :generate_stand_code, on: :create

  scope :active, -> { where(active: true) }

  private

  def generate_stand_code
    return if stand_code.present?
    loop do
      code = "STD-#{SecureRandom.alphanumeric(6).upcase}"
      unless self.class.exists?(stand_code: code)
        self.stand_code = code
        break
      end
    end
  end
end
