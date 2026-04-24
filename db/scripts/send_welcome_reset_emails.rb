# Script: Envía correo de bienvenida + enlace de reset de contraseña a todos los usuarios.
# Seguro, idempotente y respetuoso con los límites del servidor de correo.
#
# Uso en WSL (desarrollo):
#   rails runner db/scripts/send_welcome_reset_emails.rb
#
# Uso en producción:
#   RAILS_ENV=production rails runner db/scripts/send_welcome_reset_emails.rb
#
# Opciones de entorno:
#   DRY_RUN=true   → Solo muestra cuántos correos se enviarían, sin enviar nada
#   BATCH_SIZE=50  → Tamaño del lote (default: 50)
#   SKIP_IDS=1,2,3 → IDs de usuarios a omitir (ej: el admin)

DRY_RUN    = ENV.fetch("DRY_RUN",    "false") == "true"
BATCH_SIZE = ENV.fetch("BATCH_SIZE", "50").to_i
SKIP_IDS   = ENV.fetch("SKIP_IDS",  "").split(",").map(&:strip).map(&:to_i).compact

# Extender expiración del token a 7 días solo para esta ejecución
Devise.reset_password_within = 7.days

puts "\n#{"=" * 55}"
puts "  BIENVENIDA + RESET DE CONTRASEÑA — IyaiClub"
puts "  Entorno : #{Rails.env}"
puts "  Modo    : #{DRY_RUN ? '🟡 DRY RUN (sin envío real)' : '🟢 ENVÍO REAL'}"
puts "  Lotes   : #{BATCH_SIZE} usuarios/lote"
puts "  Omitir  : #{SKIP_IDS.any? ? SKIP_IDS.join(', ') : '—'}"
puts "=" * 55

scope = User.where.not(email: [nil, ""])
scope = scope.where.not(id: SKIP_IDS) if SKIP_IDS.any?

total = scope.count
puts "\n  Usuarios a notificar: #{total}\n\n"

if DRY_RUN
  puts "  DRY RUN activo — no se enviará ningún correo."
  puts "  Ejecuta sin DRY_RUN=true para enviar.\n\n"
  exit 0
end

sent      = 0
skipped   = 0
failed    = 0
batch_num = 0

scope.in_batches(of: BATCH_SIZE) do |batch|
  batch_num += 1
  batch_sent = 0

  batch.each do |user|
    begin
      # Genera token raw (legible) y token hasheado (guardado en BD)
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)

      user.update_columns(
        reset_password_token:   hashed_token,
        reset_password_sent_at: Time.current
      )

      UserMailer.welcome_with_reset(user, raw_token).deliver_later

      sent      += 1
      batch_sent += 1
    rescue => e
      failed += 1
      Rails.logger.error("[WelcomeReset] Error con user #{user.id} (#{user.email}): #{e.message}")
      puts "  ✗ Error [#{user.email}]: #{e.message}"
    end
  end

  puts "  Lote #{batch_num}: #{batch_sent} correos encolados (total: #{sent}/#{total})"
end

puts "\n#{"=" * 55}"
puts "  RESUMEN FINAL"
puts "  Encolados : #{sent}"
puts "  Omitidos  : #{skipped}"
puts "  Errores   : #{failed}"
puts "  Los correos se entregarán en background respetando"
puts "  los límites del servidor de correo."
puts "=" * 55 + "\n\n"
