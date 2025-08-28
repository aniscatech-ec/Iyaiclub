class ChangeCityToReferenceInEstablishments < ActiveRecord::Migration[8.0]
  def change
    # 1. Quitar la columna city de tipo string
    remove_column :establishments, :city, :string

    # 2. Agregar la referencia a cities
    add_reference :establishments, :city, null: false, foreign_key: true
  end
end
