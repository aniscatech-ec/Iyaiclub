class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :event_date
      t.string :location
      t.string :maps_url
      t.decimal :ticket_price, precision: 10, scale: 2
      t.integer :total_tickets
      t.integer :available_tickets
      t.string :image
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :events, :status
    add_index :events, :event_date
  end
end
