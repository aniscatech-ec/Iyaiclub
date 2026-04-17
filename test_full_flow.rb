# Script para probar el flujo completo de registro y confirmación
# Ejecutar con: rails runner test_full_flow.rb

puts "🚀 Iniciando prueba completa del flujo de email..."

# 1. Crear usuario sin confirmar
email = 'titzambralava9@gmail.com'
user = User.new(
  email: email,
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Usuario Prueba IyaiClub',
  country_id: 1,
  city_id: 1,
  birth_date: Date.new(1990, 1, 1),
  terms_accepted: true,
  marketing_consent: false
  # NOTA: confirmed_at es nil para simular registro real
)

if user.save
  puts "✅ Usuario creado exitosamente (no confirmado)"
  puts "   Email: #{user.email}"
  puts "   Confirmado: #{user.confirmed_at ? 'Sí' : 'No'}"
else
  puts "❌ Error al crear usuario:"
  user.errors.full_messages.each { |error| puts "   - #{error}" }
  exit 1
end

# 2. Enviar correo de confirmación
puts "\n📧 Enviando correo de confirmación..."
begin
  user.send_confirmation_instructions
  puts "✅ Correo de confirmación enviado"
rescue => e
  puts "❌ Error al enviar confirmación: #{e.message}"
end

# 3. Simular confirmación después de 2 segundos
puts "\n⏳ Simulando que el usuario hace clic en el enlace de confirmación..."
sleep 2

user.confirm
puts "✅ Usuario confirmado"

# 4. Verificar que se envíe el correo de bienvenida automáticamente
puts "\n🎉 El correo de bienvenida debería enviarse automáticamente..."
puts "📬 Revisa tu Gmail para ver ambos correos:"
puts "   1. Correo de confirmación (con diseño corporativo)"
puts "   2. Correo de bienvenida (con logo y gradientes)"

puts "\n📋 Resumen del usuario:"
puts "   ID: #{user.id}"
puts "   Email: #{user.email}"
puts "   Nombre: #{user.name}"
puts "   Confirmado: #{user.confirmed_at ? 'Sí' : 'No'}"
puts "   Creado: #{user.created_at}"
puts "   Confirmado en: #{user.confirmed_at}"
