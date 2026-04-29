class Stand < ApplicationRecord
  has_many :event_stands, dependent: :destroy
  has_many :events, through: :event_stands
  has_many :event_vendedores, dependent: :nullify
  belongs_to :country
  belongs_to :city

  validates :name,       presence: true
  validates :owner_name,     presence: true
  validates :owner_lastname, presence: true
  validates :stand_code, presence: true, uniqueness: true
  validates :ruc,        presence: true,
                         format: { with: /\A\d{13}\z/, message: "debe tener exactamente 13 dígitos" },
                         uniqueness: { message: "ya está registrado" }
  validates :email,      presence: true,
                         format: { with: URI::MailTo::EMAIL_REGEXP, message: "no es válido" },
                         uniqueness: { case_sensitive: false, message: "ya está registrado" }
  validate :email_not_taken_by_existing_user, on: :create

  before_validation :generate_stand_code, on: :create
  after_create      :create_stand_vendor_user

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

  def email_not_taken_by_existing_user
    if User.exists?(email: email.to_s.downcase)
      errors.add(:email, "ya pertenece a un usuario existente en la plataforma")
    end
  end

  def create_stand_vendor_user
    user = User.new(
      name:       "#{owner_name} #{owner_lastname}".strip,
      email:      email,
      role:       :vendedor,
      password:   SecureRandom.hex(16),
      country_id: country_id,
      city_id:    city_id
    )
    user.skip_confirmation!
    user.skip_role_enforcement = true

    if user.save
      # Asignar el stand al usuario mediante event_vendedor si el stand pertenece a un evento
      # (Si aún no está asignado a ningún evento, el vendedor quedará listo para asignarse)
      events.each do |event|
        next if event.event_vendedores.exists?(user: user)
        event.event_vendedores.create!(
          user:        user,
          active:      true,
          vendor_type: :stand,
          stand:       self
        )
      end

      # Enviar correo de bienvenida con enlace de creación de contraseña
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update_columns(
        reset_password_token:   hashed_token,
        reset_password_sent_at: Time.now.utc
      )
      UserMailer.welcome_stand_vendor(user, self, raw_token).deliver_now
    end
  end
end
