class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.references :establishment, null: false, foreign_key: true
      t.string :cuisine_type
      t.string :category

      t.timestamps
    end
  end
end
