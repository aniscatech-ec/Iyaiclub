#!/usr/bin/env ruby

# Script simple para enviar correo de prueba
# Ejecutar con: ruby send_simple_test_email.rb

require_relative 'config/environment'

# Crear un usuario temporal para el test
user = User.new(
  email: 'titzambralava9@gmail.com',
  name: 'Usuario de Prueba IyaiClub',
  confirmed_at: Time.current
)

puts "📧 Enviando correo de bienvenida a titzambralava9@gmail.com..."
puts "🎨 Usando el nuevo diseño con logo y colores corporativos"
puts ""

begin
  # Enviar el correo
  UserMailer.welcome_email(user).deliver_now
  
  puts "✅ Correo enviado exitosamente!"
  puts "📬 Revisa tu bandeja de entrada (incluye carpeta de spam/promociones)"
  puts "🎉 Verás el nuevo diseño con:"
  puts "   - Logo de IyaiClub"
  puts "   - Paleta de colores corporativa"
  puts "   - Iconos y animaciones"
  puts "   - Diseño responsive"
  
rescue => e
  puts "❌ Error al enviar correo:"
  puts "  #{e.class}: #{e.message}"
  puts ""
  puts "🔍 Posibles soluciones:"
  puts "  1. Verifica que las credenciales en .env sean correctas"
  puts "  2. Asegúrate que el dominio esté verificado en Brevo"
  puts "  3. Revisa la conexión a internet"
  puts ""
  puts "📋 Configuración actual:"
  puts "  SMTP_USERNAME: #{ENV['SMTP_USERNAME']&.gsub(/^(.{8}).*/, '\1...') || 'No configurado'}"
  puts "  SMTP_ADDRESS: #{ENV['SMTP_ADDRESS']}"
  puts "  SMTP_PORT: #{ENV['SMTP_PORT']}"
end
