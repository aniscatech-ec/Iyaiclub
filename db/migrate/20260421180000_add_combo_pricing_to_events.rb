class AddComboPricingToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :combo_quantity, :integer, null: true, comment: "Mínimo de tickets para activar precio combo (nil = desactivado)"
    add_column :events, :combo_discount, :decimal, precision: 10, scale: 2, null: true, comment: "Descuento por ticket cuando se compra en combo"
  end
end
