class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payphone_transaction, null: true, foreign_key: true
      t.string     :ticket_code, null: false
      t.integer    :raffle_number, null: false
      t.string     :guest_name, null: false
      t.string     :guest_email
      t.string     :guest_phone
      t.string     :event_name, null: false
      t.date       :event_date
      t.string     :event_location
      t.decimal    :unit_price, precision: 10, scale: 2
      t.decimal    :total_price, precision: 10, scale: 2
      t.integer    :status, default: 0, null: false
      t.datetime   :used_at
      t.text       :qr_data

      t.timestamps
    end

    add_index :tickets, :ticket_code, unique: true
    add_index :tickets, :raffle_number, unique: true
    add_index :tickets, :status
    add_index :tickets, :event_name
  end
end
