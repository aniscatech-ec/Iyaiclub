class AddUserToReviews < ActiveRecord::Migration[8.0]
  def change
    add_reference :reviews, :user, null: true, foreign_key: true
    remove_column :reviews, :user_name, :string
    add_index :reviews, [:user_id, :establishment_id], unique: true
  end
end
