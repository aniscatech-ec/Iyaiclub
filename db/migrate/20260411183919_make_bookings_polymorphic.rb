class MakeBookingsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Remove old index
    remove_index :bookings, :unit_id if index_exists?(:bookings, :unit_id)

    # Rename unit_id to bookable_id to maintain existing unit relations
    rename_column :bookings, :unit_id, :bookable_id

    # Add bookable_type column
    add_column :bookings, :bookable_type, :string

    # Update existing bookings to point to Unit model
    execute "UPDATE bookings SET bookable_type = 'Unit'"

    # Now make it not nullable as it is polymorphic
    change_column_null :bookings, :bookable_type, false

    # Add polymorphic index
    add_index :bookings, [:bookable_type, :bookable_id]

    # Add user_id so users can own their reservations natively
    add_reference :bookings, :user, foreign_key: true, null: true
  end

  def down
    remove_reference :bookings, :user
    remove_index :bookings, [:bookable_type, :bookable_id] if index_exists?(:bookings, [:bookable_type, :bookable_id])
    remove_column :bookings, :bookable_type
    rename_column :bookings, :bookable_id, :unit_id
    add_index :bookings, :unit_id
  end
end
