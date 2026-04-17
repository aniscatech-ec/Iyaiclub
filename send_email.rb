# Ejecutar con: rails runner send_email.rb

user = User.new(
  email: 'paul.grupogs@gmail.com',
  name: 'Usuario de Prueba IyaiClub',
  confirmed_at: Time.current
)

puts "📧 Enviando correo de bienvenida a titzambralava9@gmail.com..."

begin
  UserMailer.welcome_email(user).deliver_now
  puts "✅ Correo enviado exitosamente!"
  puts "📬 Revisa tu Gmail (inbox y spam)"
rescue => e
  puts "❌ Error: #{e.message}"
end
