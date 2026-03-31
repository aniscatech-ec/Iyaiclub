class LegalInfo < ApplicationRecord
  belongs_to :establishment

  validates :business_name, presence: { message: "Por favor ingrese la razón social o nombre comercial" },
                            length: { minimum: 3, maximum: 150, message: "La razón social debe tener al menos 3 caracteres" }

  validates :legal_representative, presence: { message: "Por favor ingrese el nombre del responsable" },
                                   length: { minimum: 3, maximum: 100, message: "El nombre del responsable debe tener al menos 3 caracteres" }

  validates :document_type, presence: { message: "Por favor seleccione el tipo de documento" }

  validates :document_number, presence: { message: "Por favor ingrese el número de documento" }
  validate :validate_document_number_format

  validates :contact_email, presence: { message: "Por favor ingrese un correo electrónico" },
                            format: { with: URI::MailTo::EMAIL_REGEXP, message: "El correo electrónico no parece válido. Ejemplo: nombre@correo.com" }

  validates :contact_phone, presence: { message: "Por favor ingrese un número de teléfono" },
                            format: { with: /\A[0-9]{10}\z/, message: "El teléfono debe tener 10 dígitos. Ejemplo: 0991234567" }

  private

  def validate_document_number_format
    return if document_number.blank? || document_type.blank?

    case document_type
    when "RUC"
      unless document_number.match?(/\A[0-9]{13}\z/)
        errors.add(:document_number, "El RUC debe tener 13 dígitos. Ejemplo: 0901234567001")
      end
    when "Cédula"
      unless document_number.match?(/\A[0-9]{10}\z/)
        errors.add(:document_number, "La cédula debe tener 10 dígitos. Ejemplo: 0901234567")
      end
    when "DNI"
      unless document_number.match?(/\A[0-9]{8,12}\z/)
        errors.add(:document_number, "El DNI debe tener entre 8 y 12 dígitos. Ejemplo: 12345678")
      end
    when "Pasaporte"
      unless document_number.match?(/\A[A-Za-z0-9]{6,15}\z/)
        errors.add(:document_number, "El pasaporte debe tener entre 6 y 15 caracteres. Ejemplo: AB1234567")
      end
    end
  end
end
