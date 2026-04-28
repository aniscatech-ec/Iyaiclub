class CreateSharedRaffleEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_raffle_events do |t|
      t.references :shared_raffle, null: false, foreign_key: true
      t.references :event,         null: false, foreign_key: true

      t.timestamps
    end

    add_index :shared_raffle_events, [:shared_raffle_id, :event_id], unique: true
  end
end
