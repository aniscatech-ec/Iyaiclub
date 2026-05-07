class AddStandIdToTicketsAndSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_reference :tickets,       :stand, foreign_key: true, null: true
    add_reference :subscriptions, :stand, foreign_key: true, null: true
  end
end
