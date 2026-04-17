class AddCancellationFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :cancelled_at, :datetime
    add_column :subscriptions, :cancellation_type, :integer, default: 0
    add_column :subscriptions, :grace_period_until, :date
  end
end
