class CreateSharedRaffleParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_raffle_participations do |t|
      t.references :shared_raffle, null: false, foreign_key: true
      t.references :ticket,        null: false, foreign_key: true
      t.integer    :participation_number, null: false
      t.timestamps
    end

    add_index :shared_raffle_participations, [:shared_raffle_id, :ticket_id],
              unique: true, name: "idx_srp_on_shared_raffle_and_ticket"
    add_index :shared_raffle_participations, [:shared_raffle_id, :participation_number],
              unique: true, name: "idx_srp_on_shared_raffle_and_number"
  end
end
