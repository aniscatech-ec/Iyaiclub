class Stand < ApplicationRecord
  has_many :event_stands, dependent: :destroy
  has_many :events, through: :event_stands
  has_many :event_vendedores, dependent: :nullify
  belongs_to :country, optional: true
  belongs_to :city, optional: true
  belongs_to :owner_user, class_name: "User", optional: true

  # Virtual attributes for user creation in the form
  attr_accessor :user_assignment_type,  # "owner" | "vendor"
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
  after_create      :assign_stand_user, if: -> { user_assignment_type.present? }

  scope :active, -> { where(active: true) }

  def vendor_users
    event_vendedores.includes(:user).map(&:user).uniq
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

  def send_welcome_email(user)
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update_columns(
      reset_password_token:   hashed_token,
      reset_password_sent_at: Time.now.utc
    )
    UserMailer.welcome_stand_vendor(user, self, raw_token).deliver_now
  end
end
