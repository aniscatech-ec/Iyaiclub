class AddFieldsToVerifications < ActiveRecord::Migration[8.0]
  def change
    add_column :verifications, :status, :integer, default: 0
    add_column :verifications, :reviewer_notes, :text
    add_column :verifications, :verified_at, :datetime
    add_column :verifications, :reviewed_by_id, :integer
  end
end
