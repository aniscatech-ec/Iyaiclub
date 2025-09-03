class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.string :method_type
      t.string :bank_name
      t.string :account_type
      t.string :account_number
      t.string :account_holder
      t.string :tax_id
      t.string :preferred_currency
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
