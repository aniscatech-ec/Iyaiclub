class AddQuotaToEventVendedores < ActiveRecord::Migration[8.0]
  def change
    add_column :event_vendedores, :quota, :integer, null: true, comment: "Cupo asignado de tickets a vender (nil = sin límite)"
    add_column :event_vendedores, :quota_met_at, :datetime, null: true, comment: "Timestamp cuando se alcanzó el cupo"
  end
end
