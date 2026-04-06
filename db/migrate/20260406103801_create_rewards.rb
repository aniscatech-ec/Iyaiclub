class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :description
      t.integer :points_required, null: false
      t.references :establishment, foreign_key: true
      t.integer :category, default: 0
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :rewards, :active
    add_index :rewards, :category
  end
end
