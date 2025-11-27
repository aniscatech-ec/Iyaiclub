class PaymentReceipt < ApplicationRecord
  belongs_to :subscription
  belongs_to :user

  has_one_attached :file # si vas a subir una imagen/pdf

  enum :status, pendiente: 0, aprobado: 1, rechazado: 2
end
