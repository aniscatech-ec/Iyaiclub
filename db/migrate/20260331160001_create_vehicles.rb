class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.references :transport, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price_per_day, precision: 8, scale: 2
      t.text :conditions

      t.timestamps
    end
  end
end
