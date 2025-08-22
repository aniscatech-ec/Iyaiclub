class CreatePlanPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_prices do |t|
      t.integer :plan_type
      t.integer :duration
      t.decimal :price

      t.timestamps
    end
  end
end
