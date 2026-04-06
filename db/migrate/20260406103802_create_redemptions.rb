class CreateRedemptions < ActiveRecord::Migration[8.0]
  def change
    create_table :redemptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true
      t.integer :points_used, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :redemptions, :status
  end
end
