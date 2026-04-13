class CreateRaffles < ActiveRecord::Migration[8.0]
  def change
    create_table :raffles, force: false do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :winning_number
      t.string :prize
      t.datetime :draw_date
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    # Agregar índices solo si no existen
    unless index_exists?(:raffles, :event_id)
      add_index :raffles, :event_id
    end

    unless index_exists?(:raffles, :status)
      add_index :raffles, :status
    end
  end
end
