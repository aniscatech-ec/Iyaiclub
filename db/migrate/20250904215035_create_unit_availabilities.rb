class CreateUnitAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :unit_availabilities do |t|
      t.references :unit, null: false, foreign_key: true
      t.date :date
      t.boolean :available

      t.timestamps
    end
  end
end
