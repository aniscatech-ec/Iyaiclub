class AddStandPricing < ActiveRecord::Migration[8.0]
  def change
    # Precio de ticket para vendedores de stand
    add_column :events, :stand_price, :decimal, precision: 8, scale: 2

    # Tipo de vendedor: normal (0) o stand (1)
    add_column :event_vendedores, :vendor_type, :integer, default: 0, null: false
  end
end
