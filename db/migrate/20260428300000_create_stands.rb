class CreateStands < ActiveRecord::Migration[8.0]
  def change
    create_table :stands do |t|
      t.string  :name,       null: false
      t.string  :location
      t.string  :stand_code, null: false
      t.boolean :active,     null: false, default: true
      t.timestamps
    end

    add_index :stands, :stand_code, unique: true

    # Tabla join evento ↔ stand
    create_table :event_stands do |t|
      t.references :event, null: false, foreign_key: true
      t.references :stand, null: false, foreign_key: true
      t.timestamps
    end

    add_index :event_stands, [:event_id, :stand_id], unique: true

    # Relación vendedor de stand ↔ stand específico
    add_reference :event_vendedores, :stand, foreign_key: true
  end
end
