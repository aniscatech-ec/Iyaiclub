class AddPlanIdToPlanPrices < ActiveRecord::Migration[8.0]
  def change
    add_reference :plan_prices, :plan, null: false, foreign_key: true
  end
end
