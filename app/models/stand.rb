class Stand < ApplicationRecord
  has_many :event_stands, dependent: :destroy
  has_many :events, through: :event_stands
  has_many :event_vendedores, dependent: :nullify
  belongs_to :country, optional: true
  belongs_to :city, optional: true
  belongs_to :owner_user, class_name: "User", optional: true

  enum :status, { reservado: 0, activo: 1 }

  # Virtual attributes for user creation in the form
  attr_accessor :user_assignment_type,  # "owner" | "vendor" | ""
                :user_source,           # "new" | "existing"
                :new_user_name,
                :new_user_lastname,
                :new_user_email,
                :new_user_ruc,
                :new_user_country_id,
                :new_user_city_id,
                :existing_user_id

  validates :name,       presence: true
  validates :stand_code, presence: true, uniqueness: true

  before_validation :generate_stand_code, on: :create
  after_create      :save_pending_user_data, if: -> { user_assignment_type.present? }

  scope :with_owner, -> { where.not(owner_user_id: nil) }
  scope :autonomous, -> { with_owner }

  # ¿Opera como entidad vendedora autónoma?
  def autonomous?
    owner_user_id.present?
  end

  # Registra el stand como vendedor autónomo en un evento (idempotente)
  def register_as_autonomo_in(event)
    return unless autonomous?
    return if event.event_vendedores.exists?(stand: self, vendor_type: :stand_autonomo)
    event.event_vendedores.create!(
      stand:       self,
      user:        nil,
      vendor_type: :stand_autonomo,
      active:      true
    )
  end

  def vendor_users
    event_vendedores.where.not(vendor_type: :stand_autonomo).includes(:user).map(&:user).compact.uniq
  end

  def has_pending_user?
    pending_user_assignment_type.present?
  end

  def send_welcome_email(user)
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update_columns(
      reset_password_token:   hashed_token,
      reset_password_sent_at: Time.now.utc
    )
    UserMailer.welcome_stand_vendor(user, self, raw_token).deliver_now
  rescue => e
    Rails.logger.error "[Stand#send_welcome_email] Error enviando correo a #{user.email}: #{e.message}"
  end

  # El admin activa el stand: crea/asigna el usuario y envía correo si corresponde
  def activate!
    return false if activo?

    if has_pending_user?
      assign_stand_user_from_pending
    end

    update!(status: :activo, active: true)
    true
  end

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

  # Guarda los datos del usuario en columnas persistentes para procesarlos al activar
  def save_pending_user_data
    update_columns(
      pending_user_assignment_type: user_assignment_type,
      pending_user_source:          user_source,
      pending_user_name:            new_user_name,
      pending_user_lastname:        new_user_lastname,
      pending_user_email:           new_user_email,
      pending_user_ruc:             new_user_ruc,
      pending_user_country_id:      new_user_country_id,
      pending_user_city_id:         new_user_city_id,
      pending_existing_user_id:     existing_user_id
    )
  end

  def assign_stand_user_from_pending
    self.user_assignment_type = pending_user_assignment_type
    self.user_source          = pending_user_source
    self.new_user_name        = pending_user_name
    self.new_user_lastname    = pending_user_lastname
    self.new_user_email       = pending_user_email
    self.new_user_ruc         = pending_user_ruc
    self.new_user_country_id  = pending_user_country_id
    self.new_user_city_id     = pending_user_city_id
    self.existing_user_id     = pending_existing_user_id

    if pending_user_assignment_type == "owner"
      assign_owner_user
    else
      assign_vendor_user
    end

    # Limpia los datos pendientes tras procesar
    update_columns(
      pending_user_assignment_type: nil,
      pending_user_source:          nil,
      pending_user_name:            nil,
      pending_user_lastname:        nil,
      pending_user_email:           nil,
      pending_user_ruc:             nil,
      pending_user_country_id:      nil,
      pending_user_city_id:         nil,
      pending_existing_user_id:     nil
    )
  end

  def assign_stand_user
    if user_assignment_type == "owner"
      assign_owner_user
    else
      assign_vendor_user
    end
  end

  def assign_owner_user
    user = resolve_user(role: :afiliado, skip_docs: true)
    return unless user
    update_columns(owner_user_id: user.id)
    events.each { |ev| register_as_autonomo_in(ev) }
    send_welcome_email(user)
  end

  def assign_vendor_user
    user = resolve_user(role: :vendedor, skip_docs: false)
    return unless user

    events.each do |event|
      next if event.event_vendedores.exists?(user: user)
      event.event_vendedores.create!(
        user:        user,
        active:      true,
        vendor_type: :stand,
        stand:       self
      )
    end
  end

  def resolve_user(role:, skip_docs:)
    if user_source == "existing"
      User.find_by(id: existing_user_id)
    else
      create_new_stand_user(role: role, skip_docs: skip_docs)
    end
  end

  def create_new_stand_user(role:, skip_docs:)
    full_name = "#{new_user_name} #{new_user_lastname}".strip
    user = User.new(
      name:       full_name,
      email:      new_user_email,
      role:       role,
      password:   SecureRandom.hex(16),
      country_id: new_user_country_id,
      city_id:    new_user_city_id
    )
    user.skip_confirmation!
    user.skip_role_enforcement = true
    user.skip_identity_documents = true if skip_docs

    if user.save
      send_welcome_email(user)
      user
    end
  end

end
