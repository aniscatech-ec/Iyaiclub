class CreateCustomRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string  :destination, null: false
      t.date    :start_date, null: false
      t.date    :end_date, null: false
      t.integer :guests_count, null: false
      t.decimal :estimated_budget, precision: 10, scale: 2
      t.integer :experience_type, null: false, default: 0
      t.text    :interests
      t.text    :preferences
      t.text    :comments
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :custom_requests, :status
    add_index :custom_requests, :experience_type
  end
end
