class RemoveUserIdFromSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_column :subscriptions, :user_id, :integer
  end
end
