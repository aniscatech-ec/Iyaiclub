# Script para generar y ver el email como archivo HTML
# Ejecutar con: rails runner view_email.rb

require_relative 'config/environment'

# Crear usuario temporal
user = User.new(
  email: 'titzambralava9@gmail.com',
  name: 'Usuario de Prueba IyaiClub',
  confirmed_at: Time.current
)

puts "📧 Generando correo de bienvenida..."

# Generar el email
mail = UserMailer.welcome_email(user)

# Guardar como archivo HTML
html_content = mail.body.decoded
File.write('welcome_email.html', html_content)

puts "✅ Email guardado como 'welcome_email.html'"
puts "📂 Abre el archivo en tu navegador para ver el diseño"
puts "🎨 Verás:"
puts "   - Logo de IyaiClub"
puts "   - Gradientes corporativos"
puts "   - Iconos y animaciones"
puts "   - Diseño responsive"

# También mostrar el contenido en consola
puts "\n" + "="*60
puts "VISTA PREVIA DEL EMAIL:"
puts "="*60
puts html_content[0..1000] + "..." if html_content.length > 1000
