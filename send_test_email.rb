#!/usr/bin/env ruby

# Script para enviar correo de bienvenida de prueba
# Ejecutar con: ruby send_test_email.rb

require_relative 'config/environment'

# Buscar o crear un usuario de prueba
email = 'titzambralava9@gmail.com'
user = User.find_by(email: email)

if user.nil?
  puts "❌ Usuario con email #{email} no encontrado."
  puts "Creando usuario de prueba..."
  
  user = User.new(
    email: email,
    password: 'password123',
    password_confirmation: 'password123',
    name: 'Usuario Prueba',
    country_id: 1,  # Ajusta según tu país existente
    city_id: 1,     # Ajusta según tu ciudad existente
    birth_date: Date.new(1990, 1, 1),
    terms_accepted: true,
    marketing_consent: false,
    confirmed_at: Time.current  # Marcar como confirmado para enviar bienvenida
  )
  
  if user.save
    puts "✅ Usuario de prueba creado exitosamente"
  else
    puts "❌ Error al crear usuario:"
    user.errors.full_messages.each { |error| puts "  - #{error}" }
    exit 1
  end
else
  puts "✅ Usuario encontrado: #{user.name || user.email}"
end

# Enviar correo de bienvenida
puts "📧 Enviando correo de bienvenida..."

begin
  # Usar el mailer que creamos
  UserMailer.welcome_email(user).deliver_now
  
  puts "✅ Correo de bienvenida enviado exitosamente a #{email}"
  puts "📬 Revisa tu bandeja de entrada (incluye carpeta de spam)"
  
rescue => e
  puts "❌ Error al enviar correo:"
  puts "  #{e.class}: #{e.message}"
  puts "\n🔍 Verifica tu configuración SMTP en .env"
  puts "  SMTP_USERNAME: #{ENV['SMTP_USERNAME']}"
  puts "  SMTP_ADDRESS: #{ENV['SMTP_ADDRESS']}"
  puts "  SMTP_PORT: #{ENV['SMTP_PORT']}"
end

puts "\n📋 Información del usuario:"
puts "  Nombre: #{user.name || 'No especificado'}"
puts "  Email: #{user.email}"
puts "  Confirmado: #{user.confirmed_at ? 'Sí' : 'No'}"
puts "  Creado: #{user.created_at}"
