class RemoveFilesFromVerifications < ActiveRecord::Migration[8.0]
  def change
    remove_column :verifications, :identity_document, :string
    remove_column :verifications, :property_document, :string
    remove_column :verifications, :selfie, :string
  end
end
