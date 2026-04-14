class CreateEventVendedores < ActiveRecord::Migration[8.0]
  def change
    create_table :event_vendedores do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :event_vendedores, [:event_id, :user_id], unique: true
  end
end
