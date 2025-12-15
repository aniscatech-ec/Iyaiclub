class CreateBookingRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_requests do |t|
      t.references :establishment, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :source
      t.string :status
      t.string :ip_address
      t.text :user_agent

      t.timestamps
    end
  end
end
