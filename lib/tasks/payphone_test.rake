# lib/tasks/payphone_test.rake
#
# Simula el flujo completo de PayPhone para verificar que el callback
# activa correctamente suscripciones y reservas.
#
# USO:
#   rails payphone:test_subscription[USER_ID,PLAN_PRICE_ID]
#   rails payphone:test_booking[BOOKING_ID]
#   rails payphone:status[CLIENT_TRANSACTION_ID]
#   rails payphone:cleanup_pending
#
# EJEMPLO:
#   rails payphone:test_subscription[5,3]
#   rails payphone:test_booking[12]

namespace :payphone do
  # ─────────────────────────────────────────────────────────────
  # TEST SUSCRIPCIÓN
  # ─────────────────────────────────────────────────────────────
  desc "Simula pago completo de suscripción. Uso: rails payphone:test_subscription[USER_ID,PLAN_PRICE_ID]"
  task :test_subscription, [:user_id, :plan_price_id] => :environment do |_, args|
    puts "\n#{"="*60}"
    puts "  TEST PAYPHONE — SUSCRIPCIÓN"
    puts "="*60

    user       = User.find(args[:user_id])
    plan_price = PlanPrice.find(args[:plan_price_id])

    puts "\nUsuario      : #{user.name} (#{user.email}) [#{user.role}]"
    puts "Plan         : #{plan_price.plan&.name} — #{plan_price.display_duration}"
    puts "Precio       : $#{plan_price.price} USD"

    # Determinar subscribable
    if user.turista?
      subscribable = user
    elsif user.afiliado?
      subscribable = user.establishments.first
      abort "  ERROR: El usuario afiliado no tiene establecimientos." unless subscribable
      puts "Establecimiento: #{subscribable.name}"
    else
      abort "  ERROR: El usuario debe ser turista o afiliado."
    end

    # Limpiar suscripciones pendientes anteriores
    old = Subscription.where(subscribable: subscribable, status: :pendiente).count
    Subscription.where(subscribable: subscribable, status: :pendiente).destroy_all
    puts "\n[LIMPIEZA] #{old} suscripción(es) pendiente(s) eliminadas" if old > 0

    # Crear suscripción pendiente
    subscription = Subscription.create!(
      subscribable:   subscribable,
      plan_type:      plan_price.id,
      payment_method: :tarjeta,
      status:         :pendiente
    )
    puts "\n[PASO 1] Suscripción creada — ID: #{subscription.id} — Estado: #{subscription.status}"

    # Crear PayphoneTransaction simulada
    client_tx_id = "TEST-SUB-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
    amount_cents = (plan_price.price * 100).to_i

    transaction = PayphoneTransaction.create!(
      payable:              subscription,
      user:                 user,
      client_transaction_id: client_tx_id,
      amount_cents:         amount_cents,
      currency:             "USD",
      email:                user.email,
      status:               :pendiente
    )
    puts "[PASO 2] PayphoneTransaction creada — ID: #{transaction.id} — Monto: $#{transaction.amount_dollars} USD"
    puts "         clientTransactionId: #{client_tx_id}"

    # Simular callback aprobado (sin llamar a PayPhone real)
    puts "\n[PASO 3] Simulando callback aprobado..."

    transaction.update!(
      transaction_id:    "SIM-#{SecureRandom.hex(6).upcase}",
      status_code:       3,
      status:            :aprobado,
      authorization_code: "AUTH-SIM-#{SecureRandom.hex(4).upcase}",
      card_brand:        "VISA",
      card_last_digits:  "1234",
      response_data:     { "statusCode" => 3, "simulated" => true }
    )

    # Activar suscripción
    subscription.set_dates
    subscription.update!(status: :activada)
    subscription.reload

    puts "\n#{"="*60}"
    puts "  RESULTADO"
    puts "="*60
    puts "Suscripción ID   : #{subscription.id}"
    puts "Estado           : #{subscription.status}"
    puts "Inicio           : #{subscription.start_date}"
    puts "Fin              : #{subscription.end_date}"
    puts "Transacción      : #{transaction.transaction_id}"
    puts "Estado pago      : #{transaction.status} (código #{transaction.status_code})"

    if subscription.activada?
      puts "\n✓ ÉXITO — La suscripción fue activada correctamente."
    else
      puts "\n✗ ERROR — La suscripción no se activó. Estado: #{subscription.status}"
    end
    puts "="*60
  end

  # ─────────────────────────────────────────────────────────────
  # TEST RESERVA
  # ─────────────────────────────────────────────────────────────
  desc "Simula pago completo de reserva. Uso: rails payphone:test_booking[BOOKING_ID_o_'new',USER_ID,UNIT_ID]"
  task :test_booking, [:booking_id, :user_id, :unit_id] => :environment do |_, args|
    puts "\n#{"="*60}"
    puts "  TEST PAYPHONE — RESERVA"
    puts "="*60

    # Si se pasa 'new', crear una reserva de prueba
    if args[:booking_id] == 'new'
      abort "  Uso para nueva reserva: rails payphone:test_booking[new,USER_ID,UNIT_ID]" unless args[:user_id] && args[:unit_id]

      user = User.find(args[:user_id])
      unit = Unit.find(args[:unit_id])
      establishment = unit.establishment

      abort "  ERROR: La unidad no tiene establecimiento." unless establishment
      abort "  ERROR: La unidad no tiene base_price definido." if unit.base_price.to_f <= 0

      start_d = Date.today + 1
      end_d   = Date.today + 3
      nights  = (end_d - start_d).to_i
      price   = nights * unit.base_price

      booking = Booking.create!(
        bookable:    unit,
        user:        user,
        guest_name:  user.name,
        guest_email: user.email,
        guest_count: 1,
        start_date:  start_d,
        end_date:    end_d,
        total_price: price,
        status:      :pendiente
      )
      puts "\n[AUTO] Reserva de prueba creada — ID: #{booking.id}"
      puts "       Unit: #{unit.unit_type} | Establecimiento: #{establishment.name}"
      puts "       Gestión: #{establishment.tipo_gestion_reserva}"
      puts "       Noches: #{nights} x $#{unit.base_price} = $#{price}"
    else
      booking = Booking.includes(bookable: :establishment).find(args[:booking_id])
      user    = booking.user || User.find_by(email: booking.guest_email)
      establishment = booking.bookable&.establishment
    end

    establishment = booking.bookable&.establishment

    puts "\nReserva ID     : #{booking.id}"
    puts "Establecimiento: #{establishment&.name || '(sin establecimiento)'}"
    puts "Servicio       : #{booking.bookable_type} ##{booking.bookable_id}"
    puts "Huésped        : #{booking.guest_name} (#{booking.guest_email})"
    puts "Fechas         : #{booking.start_date} → #{booking.end_date}"
    puts "Total          : $#{booking.total_price} USD"
    puts "Estado actual  : #{booking.status}"
    puts "Gestión        : #{establishment&.tipo_gestion_reserva || '(no definida)'}"

    abort "\n  ERROR: Esta reserva ya no está pendiente (#{booking.status})." unless booking.pendiente?
    abort "\n  ERROR: Total es 0 — no se puede procesar pago." if booking.total_price.to_f <= 0
    abort "\n  ERROR: No se encontró usuario para esta reserva." unless user

    # Crear PayphoneTransaction simulada
    client_tx_id = "TEST-BKG-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}"
    amount_cents = (booking.total_price * 100).to_i

    transaction = PayphoneTransaction.create!(
      payable:               booking,
      user:                  user,
      client_transaction_id: client_tx_id,
      amount_cents:          amount_cents,
      currency:              "USD",
      email:                 user.email,
      status:                :pendiente
    )
    puts "\n[PASO 1] PayphoneTransaction creada — ID: #{transaction.id}"
    puts "         clientTransactionId: #{client_tx_id}"

    # Simular callback aprobado
    puts "[PASO 2] Simulando callback aprobado..."

    transaction.update!(
      transaction_id:    "SIM-#{SecureRandom.hex(6).upcase}",
      status_code:       3,
      status:            :aprobado,
      authorization_code: "AUTH-SIM-#{SecureRandom.hex(4).upcase}",
      card_brand:        "VISA",
      card_last_digits:  "1234",
      response_data:     { "statusCode" => 3, "simulated" => true }
    )

    # Activar reserva
    booking.update!(status: :confirmado)
    booking.reload

    puts "\n#{"="*60}"
    puts "  RESULTADO"
    puts "="*60
    puts "Reserva ID     : #{booking.id}"
    puts "Estado         : #{booking.status}"
    puts "Transacción    : #{transaction.transaction_id}"
    puts "Estado pago    : #{transaction.status} (código #{transaction.status_code})"

    if booking.confirmado?
      puts "\n✓ ÉXITO — La reserva fue confirmada correctamente."
    else
      puts "\n✗ ERROR — La reserva no se confirmó. Estado: #{booking.status}"
    end
    puts "="*60
  end

  # ─────────────────────────────────────────────────────────────
  # VERIFICAR ESTADO DE TRANSACCIÓN REAL EN PAYPHONE
  # ─────────────────────────────────────────────────────────────
  desc "Consulta el estado real de una transacción en PayPhone. Uso: rails payphone:status[CLIENT_TX_ID]"
  task :status, [:client_tx_id] => :environment do |_, args|
    puts "\n#{"="*60}"
    puts "  ESTADO TRANSACCIÓN PAYPHONE"
    puts "="*60

    client_tx_id = args[:client_tx_id]
    transaction  = PayphoneTransaction.find_by(client_transaction_id: client_tx_id)

    if transaction
      puts "\nTransacción local encontrada:"
      puts "  ID local          : #{transaction.id}"
      puts "  Payable           : #{transaction.payable_type} ##{transaction.payable_id}"
      puts "  Monto             : $#{transaction.amount_dollars} USD"
      puts "  Estado local      : #{transaction.status}"
      puts "  transaction_id    : #{transaction.transaction_id}"
      puts "  authorization_code: #{transaction.authorization_code}"
      puts "  Tarjeta           : #{transaction.card_brand} ****#{transaction.card_last_digits}"
      puts "  Email             : #{transaction.email}"
      puts "  Creada            : #{transaction.created_at&.strftime("%d/%m/%Y %H:%M")}"

      if transaction.transaction_id.present? && !transaction.transaction_id.start_with?("SIM-")
        puts "\nConsultando PayPhone API..."
        service = PayphoneService.new
        result  = service.confirm(id: transaction.transaction_id.to_i, client_tx_id: client_tx_id)

        if result[:success]
          data = result[:data]
          puts "\nRespuesta PayPhone:"
          puts "  statusCode       : #{data['statusCode']}"
          puts "  transactionStatus: #{data['transactionStatus']}"
          puts "  authorizationCode: #{data['authorizationCode']}"
          puts "  amount           : #{data['amount']}"
          puts "  message          : #{data['message']}"
        else
          puts "  ERROR consultando PayPhone: #{result[:error]}"
        end
      else
        puts "\n(Transacción simulada — no se consulta PayPhone API)"
      end
    else
      puts "\n  No se encontró transacción con clientTransactionId: #{client_tx_id}"
    end
    puts "="*60
  end

  # ─────────────────────────────────────────────────────────────
  # LISTAR RECURSOS DISPONIBLES PARA TEST
  # ─────────────────────────────────────────────────────────────
  desc "Lista usuarios, units y planes disponibles para hacer tests"
  task info: :environment do
    puts "\n#{"="*60}"
    puts "  RECURSOS DISPONIBLES PARA TEST"
    puts "="*60

    puts "\n--- USUARIOS ---"
    User.order(:id).limit(10).each do |u|
      puts "  [#{u.id}] #{u.name.ljust(20)} #{u.email.ljust(30)} role: #{u.role}"
    end

    puts "\n--- PLANES (PlanPrice) ---"
    PlanPrice.includes(:plan).order(:id).each do |pp|
      puts "  [#{pp.id}] #{pp.plan&.name.to_s.ljust(20)} #{pp.display_duration.ljust(12)} $#{pp.price} | rol: #{pp.target_role}"
    end

    puts "\n--- UNITS con precio ---"
    Unit.includes(:establishment).where.not(base_price: [nil, 0]).limit(10).each do |u|
      gestion = u.establishment&.tipo_gestion_reserva || "?"
      puts "  [#{u.id}] #{u.unit_type.to_s.ljust(15)} $#{u.base_price.to_s.ljust(8)} estab: #{u.establishment&.name.to_s.ljust(20)} gestión: #{gestion}"
    end

    puts "\n--- RESERVAS PENDIENTES con bookable ---"
    Booking.pendiente.includes(bookable: :establishment).where.not(bookable_type: nil).last(5).each do |b|
      puts "  [#{b.id}] #{b.bookable_type}##{b.bookable_id} | $#{b.total_price} | #{b.bookable&.establishment&.name}"
    end

    puts "\n#{"="*60}"
  end

  # ─────────────────────────────────────────────────────────────
  # LISTAR TRANSACCIONES RECIENTES
  # ─────────────────────────────────────────────────────────────
  desc "Lista las últimas 10 transacciones PayPhone"
  task recent: :environment do
    puts "\n#{"="*60}"
    puts "  ÚLTIMAS 10 TRANSACCIONES PAYPHONE"
    puts "="*60

    transactions = PayphoneTransaction.order(created_at: :desc).limit(10)

    if transactions.empty?
      puts "\n  No hay transacciones registradas."
    else
      transactions.each do |t|
        payable_info = t.payable ? "#{t.payable_type}##{t.payable_id}" : "nil"
        puts "\n  [#{t.id}] #{t.created_at&.strftime("%d/%m %H:%M")} | " \
             "#{t.status.upcase.ljust(10)} | " \
             "$#{'%.2f' % t.amount_dollars} | " \
             "#{payable_info.ljust(20)} | " \
             "#{t.client_transaction_id}"
      end
    end
    puts "\n#{"="*60}"
  end

  # ─────────────────────────────────────────────────────────────
  # LIMPIAR TRANSACCIONES Y SUSCRIPCIONES PENDIENTES
  # ─────────────────────────────────────────────────────────────
  desc "Elimina transacciones simuladas y suscripciones pendientes de prueba"
  task cleanup_pending: :environment do
    puts "\n#{"="*60}"
    puts "  LIMPIEZA DE DATOS DE PRUEBA"
    puts "="*60

    sim_txs = PayphoneTransaction.where("client_transaction_id LIKE 'TEST-%'")
    puts "\nTransacciones de prueba (TEST-*): #{sim_txs.count}"
    sim_txs.destroy_all
    puts "  → Eliminadas."

    pending_subs = Subscription.where(status: :pendiente)
    puts "Suscripciones pendientes        : #{pending_subs.count}"
    pending_subs.each do |s|
      puts "  → Sub ##{s.id} | #{s.subscribable_type}##{s.subscribable_id}"
    end

    puts "\n¿Eliminar suscripciones pendientes? (escribe 'si' y presiona Enter)"
    input = STDIN.gets.chomp
    if input.downcase == "si"
      pending_subs.destroy_all
      puts "  → Eliminadas."
    else
      puts "  → Omitido."
    end

    puts "\n✓ Limpieza completada."
    puts "="*60
  end
end
