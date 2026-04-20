class MakeUserOptionalOnTicketsAndPayphoneTransactions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tickets, :user_id, true
    change_column_null :payphone_transactions, :user_id, true
  end
end
