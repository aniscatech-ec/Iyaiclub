class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.string :unit_type
      t.integer :capacity
      t.integer :beds
      t.decimal :base_price
      t.text :seasonal_prices
      t.boolean :available
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
