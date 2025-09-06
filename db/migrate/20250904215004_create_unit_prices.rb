class CreateUnitPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_prices do |t|
      t.references :unit, null: false, foreign_key: true
      t.string :season
      t.decimal :price

      t.timestamps
    end
  end
end
