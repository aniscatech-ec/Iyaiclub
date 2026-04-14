class AddTransferFieldsToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :payment_method, :integer, default: 0, null: false
    add_column :tickets, :vendedor_id, :bigint, null: true
    add_column :tickets, :reserved_at, :datetime, null: true

    add_index :tickets, :payment_method
    add_index :tickets, :vendedor_id
    add_foreign_key :tickets, :users, column: :vendedor_id
  end
end
