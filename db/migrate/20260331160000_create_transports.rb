class CreateTransports < ActiveRecord::Migration[8.0]
  def change
    create_table :transports do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :transport_type, null: false
      t.string :subcategory, null: false
      t.integer :capacity
      t.text :service_description
      t.string :price_range

      t.timestamps
    end

    add_index :transports, :transport_type
    add_index :transports, :subcategory
  end
end
