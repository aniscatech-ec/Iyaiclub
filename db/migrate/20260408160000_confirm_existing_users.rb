class ConfirmExistingUsers < ActiveRecord::Migration[8.0]
  def up
    # Marcar como confirmados a todos los usuarios que ya existían antes
    # de activar :confirmable en Devise. Esto evita que queden bloqueados
    # al iniciar sesión.
    User.where(confirmed_at: nil).update_all(confirmed_at: Time.current)
  end

  def down
    # No revertir: marcar usuarios como no confirmados podría dejar la app
    # en un estado inconsistente.
  end
end
