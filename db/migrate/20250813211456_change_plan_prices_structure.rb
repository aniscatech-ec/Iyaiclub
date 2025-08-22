class ChangePlanPricesStructure < ActiveRecord::Migration[8.0]
  def change
    # Cambiar tipo de 'name' a string
    change_column :plan_prices, :plan_type, :string

    # Asegurar que duration_months sea integer
    change_column :plan_prices, :duration, :integer, default: 0
    # ejemplo migración
    change_column :plan_prices, :price, :decimal, precision: 10, scale: 2, default: 0.0

  end
end
