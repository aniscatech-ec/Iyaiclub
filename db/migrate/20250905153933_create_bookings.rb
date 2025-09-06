class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :unit, null: false, foreign_key: true
      t.string :guest_name
      t.string :guest_email
      t.integer :guest_count
      t.date :start_date
      t.date :end_date
      t.decimal :total_price, precision: 10, scale: 2
      t.string :status

      t.timestamps
    end
  end
end
