class CreateUserPoints < ActiveRecord::Migration[8.0]
  def change
    create_table :user_points do |t|
      t.references :user, null: false, foreign_key: true
      t.references :establishment, null: false, foreign_key: true
      t.integer :points_earned, null: false, default: 0
      t.string :description

      t.timestamps
    end

    add_index :user_points, [:user_id, :created_at]
  end
end
