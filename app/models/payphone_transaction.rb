class PayphoneTransaction < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :user

  enum :status, { pendiente: 0, aprobado: 1, cancelado: 2, revertido: 3 }

  validates :client_transaction_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }

  def amount_dollars
    amount_cents / 100.0
  end

  def approved?
    status_code == 3
  end

  def cancelled?
    status_code == 2
  end
end
