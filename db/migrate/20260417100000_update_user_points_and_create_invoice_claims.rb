class UpdateUserPointsAndCreateInvoiceClaims < ActiveRecord::Migration[8.0]
  def change
    # Hacer establishment_id opcional en user_points
    # (para puntos de bienvenida, membresía, etc. que no tienen establecimiento)
    change_column_null :user_points, :establishment_id, true

    # Agregar source (origen del punto) y metadata a user_points
    add_column :user_points, :source, :integer, default: 0, null: false
    add_column :user_points, :metadata, :text
    add_index :user_points, :source

    # Tabla de solicitudes de acreditación por factura
    create_table :invoice_claims do |t|
      t.references :user,          null: false, foreign_key: true
      t.references :establishment, null: true,  foreign_key: true
      t.string  :invoice_number
      t.decimal :amount,           precision: 10, scale: 2, null: false
      t.text    :description
      t.string  :invoice_file
      t.integer :status,           default: 0, null: false   # pendiente, aprobada, rechazada
      t.integer :points_granted
      t.text    :admin_notes
      t.references :reviewed_by,   null: true, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end
    add_index :invoice_claims, :status
  end
end
