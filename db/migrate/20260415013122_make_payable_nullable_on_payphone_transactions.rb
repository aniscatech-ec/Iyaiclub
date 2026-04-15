class MakePayableNullableOnPayphoneTransactions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :payphone_transactions, :payable_type, true
    change_column_null :payphone_transactions, :payable_id, true
    add_column :payphone_transactions, :metadata, :json
  end
end
