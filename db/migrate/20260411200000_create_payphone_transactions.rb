class CreatePayphoneTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :payphone_transactions do |t|
      t.references :payable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.bigint     :transaction_id
      t.string     :client_transaction_id, null: false
      t.integer    :amount_cents, null: false
      t.string     :currency, default: "USD"
      t.integer    :status, default: 0, null: false
      t.integer    :status_code
      t.string     :authorization_code
      t.string     :card_brand
      t.string     :card_last_digits
      t.string     :phone_number
      t.string     :email
      t.json       :response_data

      t.timestamps
    end

    add_index :payphone_transactions, :client_transaction_id, unique: true
    add_index :payphone_transactions, :transaction_id
    add_index :payphone_transactions, :status
  end
end
