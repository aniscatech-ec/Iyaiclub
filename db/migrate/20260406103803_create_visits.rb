class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :establishment, null: false, foreign_key: true
      t.datetime :visited_at, null: false
      t.integer :source, default: 0

      t.timestamps
    end

    add_index :visits, [:user_id, :establishment_id]
    add_index :visits, :visited_at
  end
end
