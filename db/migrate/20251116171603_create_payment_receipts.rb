class CreatePaymentReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_receipts do |t|
      t.references :subscription, null: false, foreign_key: true
      t.integer :status
      t.references :user, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
