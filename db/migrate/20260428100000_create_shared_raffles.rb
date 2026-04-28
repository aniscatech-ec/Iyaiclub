class CreateSharedRaffles < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_raffles do |t|
      t.string   :name,           null: false
      t.string   :prize,          null: false
      t.text     :description
      t.datetime :draw_date
      t.integer  :winning_number
      t.integer  :status,         null: false, default: 0

      t.timestamps
    end

    add_index :shared_raffles, :status
  end
end
