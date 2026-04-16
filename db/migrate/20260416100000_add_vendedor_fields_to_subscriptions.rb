class AddVendedorFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_reference :subscriptions, :vendedor, null: true, foreign_key: { to_table: :users }
    add_column    :subscriptions, :reserved_at, :datetime
  end
end
