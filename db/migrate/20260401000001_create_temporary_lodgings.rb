class CreateTemporaryLodgings < ActiveRecord::Migration[7.1]
  def change
    create_table :temporary_lodgings do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :lodging_type, null: false

      t.timestamps
    end
    add_index :temporary_lodgings, :lodging_type
  end
end
