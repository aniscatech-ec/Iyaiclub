class MakeSubscriptionsPolymorphic < ActiveRecord::Migration[8.0]
  def change
    # Paso 1: agregar columnas polimórficas
    add_reference :subscriptions, :subscribable, polymorphic: true, null: false

    # Paso 2: si ya tienes establishment_id, puedes migrar datos
    # execute "UPDATE subscriptions SET subscribable_id = establishment_id, subscribable_type = 'Establishment'"

    # Paso 3: elimina la columna vieja si ya no se usará
    remove_column :subscriptions, :establishment_id, :integer
  end
end
