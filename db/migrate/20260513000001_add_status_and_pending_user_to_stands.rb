class AddStatusAndPendingUserToStands < ActiveRecord::Migration[8.0]
  def change
    add_column :stands, :status, :integer, default: 0, null: false
    add_column :stands, :pending_user_assignment_type, :string
    add_column :stands, :pending_user_source, :string
    add_column :stands, :pending_user_name, :string
    add_column :stands, :pending_user_lastname, :string
    add_column :stands, :pending_user_email, :string
    add_column :stands, :pending_user_ruc, :string
    add_column :stands, :pending_user_country_id, :bigint
    add_column :stands, :pending_user_city_id, :bigint
    add_column :stands, :pending_existing_user_id, :bigint

    # Stands existentes quedan como activos
    reversible do |dir|
      dir.up { Stand.update_all(status: 1) }
    end

    add_index :stands, :status
  end
end
