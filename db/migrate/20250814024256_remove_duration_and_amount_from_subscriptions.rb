class RemoveDurationAndAmountFromSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_column :subscriptions, :duration, :integer
    remove_column :subscriptions, :amount, :decimal
  end
end
