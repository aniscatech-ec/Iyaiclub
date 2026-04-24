class BankAccount < ApplicationRecord
  INSTITUTIONS = [
    "Banco Pichincha", "Banco Guayaquil", "Banco Pacífico", "Banco Internacional",
    "Banco Bolivariano", "Banco del Austro", "Produbanco", "Bancodesarrollo",
    "Cooperativa JEP", "Cooperativa Jardín Azuayo", "Cooperativa 29 de Octubre",
    "Cooperativa Policía Nacional", "Biess", "Otro"
  ].freeze

  ACCOUNT_TYPES = %w[ahorros corriente].freeze

  IDENTIFIER_TYPES = %w[cedula ruc].freeze

  ACCOUNT_NUMBER_LENGTHS = {
    "Banco Pichincha"              => 10,
    "Banco Guayaquil"              => 10,
    "Banco Pacífico"               => 10,
    "Banco Internacional"          => 10,
    "Banco Bolivariano"            => 10,
    "Banco del Austro"             => 10,
    "Produbanco"                   => 10,
    "Bancodesarrollo"              => 10,
    "Cooperativa JEP"              => 13,
    "Cooperativa Jardín Azuayo"    => 13,
    "Cooperativa 29 de Octubre"    => 13,
    "Cooperativa Policía Nacional" => 13,
    "Biess"                        => 14
    # "Otro" has no restriction
  }.freeze

  validates :institution,     presence: true, inclusion: { in: INSTITUTIONS }
  validates :account_type,    presence: true, inclusion: { in: ACCOUNT_TYPES }
  validates :account_number,  presence: true, format: { with: /\A\d+\z/, message: "solo puede contener dígitos", allow_blank: true }
  validates :owner_name,      presence: true
  validates :identifier,      presence: true, format: { with: /\A\d+\z/, message: "solo puede contener dígitos", allow_blank: true }
  validates :identifier_type, presence: true, inclusion: { in: IDENTIFIER_TYPES }
  validates :active,          inclusion: { in: [true, false] }

  validate :account_number_length_matches_institution
  validate :identifier_length_matches_type

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(:institution, :owner_name) }

  def account_type_label
    account_type == "ahorros" ? "Ahorros" : "Corriente"
  end

  def identifier_type_label
    identifier_type == "cedula" ? "Cédula" : "RUC"
  end

  private

  IDENTIFIER_LENGTHS = { "cedula" => 10, "ruc" => 13 }.freeze

  def account_number_length_matches_institution
    return if institution.blank? || account_number.blank?
    return unless account_number.match?(/\A\d+\z/)

    expected = ACCOUNT_NUMBER_LENGTHS[institution]
    return if expected.nil? # "Otro" — no restriction

    unless account_number.length == expected
      errors.add(:account_number, "debe tener exactamente #{expected} dígitos para #{institution} (tiene #{account_number.length})")
    end
  end

  def identifier_length_matches_type
    return if identifier_type.blank? || identifier.blank?
    return unless identifier.match?(/\A\d+\z/)

    expected = IDENTIFIER_LENGTHS[identifier_type]
    return if expected.nil?

    unless identifier.length == expected
      label = identifier_type == "cedula" ? "Cédula" : "RUC"
      errors.add(:identifier, "#{label} debe tener exactamente #{expected} dígitos (tiene #{identifier.length})")
    end
  end
end
