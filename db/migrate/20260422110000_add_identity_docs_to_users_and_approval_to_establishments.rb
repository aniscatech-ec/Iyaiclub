class AddIdentityDocsToUsersAndApprovalToEstablishments < ActiveRecord::Migration[8.0]
  def change
    # Establecimientos: estado de aprobación explícito
    add_column :establishments, :approval_status, :integer, default: 0, null: false,
               comment: "0=pending, 1=approved, 2=rejected"
    add_column :establishments, :approval_notes, :string, null: true,
               comment: "Motivo del rechazo si aplica"
    add_column :establishments, :approved_at, :datetime, null: true
    add_column :establishments, :approved_by_id, :bigint, null: true

    add_index :establishments, :approval_status
  end
end
