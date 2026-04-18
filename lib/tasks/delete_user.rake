namespace :users do
  desc "Elimina un usuario y todos sus registros anidados. Uso: rails users:delete ID=551"
  task delete: :environment do
    user_id = ENV["ID"].to_i
    abort "ERROR: Debes pasar el ID del usuario. Ejemplo: rails users:delete ID=551" if user_id.zero?

    user = User.find_by(id: user_id)
    abort "ERROR: No se encontró un usuario con ID=#{user_id}" unless user

    puts "═" * 50
    puts "  Eliminando usuario: #{user.name} (#{user.email})"
    puts "═" * 50

    steps = [
      ["Puntos",              -> { user.user_points.destroy_all }],
      ["Canjes",              -> { user.redemptions.destroy_all }],
      ["Visitas",             -> { user.visits.destroy_all }],
      ["Facturas",            -> { user.invoice_claims.destroy_all }],
      ["Tickets",             -> { user.tickets.destroy_all }],
      ["Reservas",            -> { user.bookings.destroy_all }],
      ["Solicitudes custom",  -> { user.custom_requests.destroy_all }],
      ["Event vendedores",    -> { user.event_vendedores.destroy_all }],
      ["Suscripciones",       -> { Subscription.where(subscribable_type: "User", subscribable_id: user_id).destroy_all }],
      ["Transacciones PayPhone", -> { PayphoneTransaction.where(user_id: user_id).destroy_all }],
      ["Nullify tickets vendedor", -> { Ticket.where(vendedor_id: user_id).update_all(vendedor_id: nil) }],
      ["Nullify solicitudes asignadas", -> { CustomRequest.where(assigned_to_id: user_id).update_all(assigned_to_id: nil) }],
      ["Nullify facturas revisadas", -> { InvoiceClaim.where(reviewed_by_id: user_id).update_all(reviewed_by_id: nil) }],
      ["Establecimientos",    -> { user.establishments.each(&:destroy) }],
    ]

    steps.each do |label, action|
      print "  → #{label}... "
      begin
        action.call
        puts "✓"
      rescue => e
        puts "✗ ERROR: #{e.message}"
        abort "Proceso cancelado. Revisa el error anterior."
      end
    end

    print "  → Usuario... "
    user.destroy
    puts "✓"

    puts "═" * 50
    puts "  Usuario ID=#{user_id} eliminado correctamente."
    puts "═" * 50
  end
end
