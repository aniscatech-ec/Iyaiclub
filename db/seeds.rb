# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# CREACION DE 50 AFILIADOS Y 50 TURISTAS*****************************************************
# require "faker"
#
# # Crear 50 afiliados
# 50.times do
#   User.create!(
#     email: Faker::Internet.unique.email,
#     password: "123456",
#     name: Faker::Name.name,
#     phone: Faker::PhoneNumber.cell_phone,
#     role: :afiliado,
#     country_id: Country.all.sample&.id,
#     city_id: City.all.sample&.id,
#     birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
#     terms_accepted: true,
#     marketing_consent: [true, false].sample
#   )
# end
#
# # Crear 30 turistas
# 30.times do
#   User.create!(
#     email: Faker::Internet.unique.email,
#     password: "123456",
#     name: Faker::Name.name,
#     phone: Faker::PhoneNumber.cell_phone,
#     role: :turista,
#     country_id: Country.all.sample&.id,
#     city_id: City.all.sample&.id,
#     birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
#     terms_accepted: true,
#     marketing_consent: [true, false].sample
#   )
# end
# CREACION DE 50 AFILIADOS Y 50 TURISTAS*****************************************************
# db/seeds.rb

# db/seeds.rb

# db/seeds.rb
# db/seeds.rb

# representatives = [
#   "Carlos Pérez", "María Rodríguez", "José González", "Ana Torres",
#   "Luis Herrera", "Gabriela Castro", "Jorge Mendoza", "Sofía Vega",
#   "Ricardo Morales", "Fernanda Sánchez", "Andrés Paredes", "Carolina Ríos",
#   "Miguel Vaca", "Patricia León", "Hernán López", "Daniela Guerrero",
#   "Cristian Almeida", "Valeria Jaramillo", "Mauricio Molina", "Camila Flores",
#   "Sebastián Castillo", "Laura Zamora", "Felipe Cárdenas", "Alejandra Aguirre",
#   "Pablo Ortega", "Mónica Villalba", "Esteban Franco", "Claudia Meza",
#   "Francisco Hidalgo", "Lucía Cedeño", "Diego Vera", "Paola Chávez",
#   "Javier Narváez", "Silvia Jiménez", "Gustavo Quiroz", "Natalia Acosta",
#   "Ramiro Pino", "Verónica Bustamante", "Hugo Ibarra", "Diana Correa",
#   "Álvaro Rueda", "Marisol Villavicencio", "César Paredes", "Rosa Cárdenas",
#   "Fabián Castillo", "Inés Romero", "Tomás Medina", "Lorena Grijalva",
#   "Óscar Cabrera", "Karla Muñoz", "Iván Benítez", "Martha Villacís",
#   "Raúl Carrillo", "Sandra Peralta", "Fernando Robles", "Tatiana Villamil",
#   "Jaime Lema", "Nadia Cabrera", "Guillermo Pazmiño", "Elena Torres",
#   "Rubén Espinoza", "Carla Manrique", "Héctor Bravo", "Gloria Alvarado",
#   "Santiago Borja", "Julia Castillo", "Víctor Ruiz", "Marcela Andrade",
#   "Edgar Beltrán", "Rocío Villacrés", "Darío Morales", "Aleida Salazar",
#   "Martín Villamil", "Margarita Cueva", "Rodrigo Palacios", "Angela Beltrán",
#   "Pedro Montalvo", "Isabel Montero", "Nelson Fierro", "Beatriz Ortiz",
#   "Edison Jiménez", "Carmen Salinas", "Wilson Chacón", "Susana Molina",
#   "Ángel Herrera", "Mariela Viteri", "Orlando Castro", "Luisa Herrera",
#   "Hernando Vallejo", "Teresa Almeida", "David Reinoso", "Nelly Tapia",
#   "Marco Rivas", "Ximena Corral", "Adrián Salazar", "Paty Montenegro",
#   "Vicente Ruiz", "Florencia Zambrano", "Alex Cisneros", "Ruth Palacios",
#   "Cristóbal León", "Emilia Andrade", "Mateo Viteri", "Clara Maldonado",
#   "Iván Calle", "Daniela Mena", "Roberto Pinos", "Andrea Torres"
# ]
#
# business_names = [
#   "Comercial Andina S.A.",
#   "Servicios Globales Cía. Ltda.",
#   "Inversiones del Sol S.A.",
#   "Constructora Horizonte Cía. Ltda.",
#   "Alimentos Sierra Dorada S.A.",
#   "Distribuidora El Faro Cía. Ltda.",
#   "Tecnología y Progreso S.A.",
#   "Agroexportadora Nevado Cía. Ltda.",
#   "Turismo Imperial S.A.",
#   "Textiles del Valle Cía. Ltda.",
#   "Logística Integral S.A.",
#   "Farmacéutica Aurora Cía. Ltda.",
#   "Hoteles Encanto S.A.",
#   "Consultores del Norte Cía. Ltda.",
#   "Restaurantes Brisas S.A.",
#   "Automotores Andinos Cía. Ltda.",
#   "Servicios Financieros Real S.A.",
#   "Panificadora Dorada Cía. Ltda.",
#   "Energía Viva S.A.",
#   "Transportes del Sur Cía. Ltda."
# ]
#
# # Recorremos todos los LegalInfo y actualizamos legal_representative + business_name
# LegalInfo.find_each.with_index do |legal_info, i|
#   rep_name = representatives[i % representatives.size]
#   biz_name = business_names[i % business_names.size]
#
#   legal_info.update!(
#     legal_representative: rep_name,
#     business_name: biz_name
#   )
# end


# db/seeds.rb

# Seleccionar solo los establecimientos con categoría 'hotel'
# db/seeds.rb

# ... aquí va tu código de actualización de precios ...

# Comprobación: listar hoteles con precio hasta 120
# cheap_hotels = Establishment.where(category: "hotel").where("price_per_night <= ?", 120.0)
#
# if cheap_hotels.any?
#   puts "🏨 Hoteles con precio hasta $120.00:"
#   cheap_hotels.each do |hotel|
#     puts "- #{hotel.name}: $#{hotel.price_per_night}"
#   end
# else
#   puts "⚠️ No hay hoteles con precio <= $120.00."
# end
# puts "Total de hoteles con precio <= 120: #{cheap_hotels.count}"

puts ">>> Todos los hoteles:"
Hotel.includes(establishment: [:amenities, :city]).each do |hotel|
  est = hotel.establishment
  amenities = est.amenities.pluck(:name).join(", ")
  city_name = est.city&.name || "-"
  puts "#{est.name} - #{city_name} - $#{est.price_per_night} | Amenities: #{amenities}"
end

puts "----------------------------------------------------------"

# amenity_names = ["Wi-Fi gratis", "Cocina"]
amenity_names = ["TV por cable"]
amenity_ids = Amenity.where(name: amenity_names).pluck(:id)

establishment_ids = Establishment.joins(:amenities)
                                 .where(amenities: { id: amenity_ids })
                                 .group("establishments.id")
                                 .having("COUNT(DISTINCT amenities.id) = ?", amenity_ids.size)
                                 .pluck(:id)

hotels = Hotel.joins(:establishment)
              .where(establishments: { id: establishment_ids })

puts ">>> Hoteles con amenities #{amenity_names.join(', ')} (#{hotels.count}):"
hotels.each do |hotel|
  amenities = hotel.establishment.amenities.pluck(:name).join(", ")
  puts "#{hotel.establishment.name} - #{hotel.establishment.city.name} - $#{hotel.establishment.price_per_night} | Amenities: #{amenities}"
end

puts "--------------------------------------------------------"
puts ">>> Hoteles en Quito:"
# Encontramos la ciudad Quito
quito = City.find_by(name: "Quito")

if quito
  x = 0
  Hotel.joins(:establishment)
       .where(establishments: { city_id: quito.id })
       .includes(establishment: [:amenities, :city])
       .each do |hotel|
    est = hotel.establishment
    amenities = est.amenities.pluck(:name).join(", ")
    city_name = est.city&.name || "-"
    puts "#{est.name} - #{city_name} - $#{est.price_per_night} | Amenities: #{amenities}"
    x=x+1
  end
  puts x
else
  puts "No se encontró la ciudad Quito"
end
