class CreateExperiences < ActiveRecord::Migration[7.1]
  def change
    create_table :experiences do |t|
      t.string :name, null: false
      t.text :description
      t.string :duration
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :requirements
      t.references :establishment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
