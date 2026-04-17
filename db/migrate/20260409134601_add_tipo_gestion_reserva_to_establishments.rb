class AddTipoGestionReservaToEstablishments < ActiveRecord::Migration[8.0]
  def change
    add_column :establishments, :tipo_gestion_reserva, :integer, default: 0, null: false
    add_index :establishments, :tipo_gestion_reserva
  end
end
