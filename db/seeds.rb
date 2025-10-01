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

representatives = [
  "Carlos Pérez", "María Rodríguez", "José González", "Ana Torres",
  "Luis Herrera", "Gabriela Castro", "Jorge Mendoza", "Sofía Vega",
  "Ricardo Morales", "Fernanda Sánchez", "Andrés Paredes", "Carolina Ríos",
  "Miguel Vaca", "Patricia León", "Hernán López", "Daniela Guerrero",
  "Cristian Almeida", "Valeria Jaramillo", "Mauricio Molina", "Camila Flores",
  "Sebastián Castillo", "Laura Zamora", "Felipe Cárdenas", "Alejandra Aguirre",
  "Pablo Ortega", "Mónica Villalba", "Esteban Franco", "Claudia Meza",
  "Francisco Hidalgo", "Lucía Cedeño", "Diego Vera", "Paola Chávez",
  "Javier Narváez", "Silvia Jiménez", "Gustavo Quiroz", "Natalia Acosta",
  "Ramiro Pino", "Verónica Bustamante", "Hugo Ibarra", "Diana Correa",
  "Álvaro Rueda", "Marisol Villavicencio", "César Paredes", "Rosa Cárdenas",
  "Fabián Castillo", "Inés Romero", "Tomás Medina", "Lorena Grijalva",
  "Óscar Cabrera", "Karla Muñoz", "Iván Benítez", "Martha Villacís",
  "Raúl Carrillo", "Sandra Peralta", "Fernando Robles", "Tatiana Villamil",
  "Jaime Lema", "Nadia Cabrera", "Guillermo Pazmiño", "Elena Torres",
  "Rubén Espinoza", "Carla Manrique", "Héctor Bravo", "Gloria Alvarado",
  "Santiago Borja", "Julia Castillo", "Víctor Ruiz", "Marcela Andrade",
  "Edgar Beltrán", "Rocío Villacrés", "Darío Morales", "Aleida Salazar",
  "Martín Villamil", "Margarita Cueva", "Rodrigo Palacios", "Angela Beltrán",
  "Pedro Montalvo", "Isabel Montero", "Nelson Fierro", "Beatriz Ortiz",
  "Edison Jiménez", "Carmen Salinas", "Wilson Chacón", "Susana Molina",
  "Ángel Herrera", "Mariela Viteri", "Orlando Castro", "Luisa Herrera",
  "Hernando Vallejo", "Teresa Almeida", "David Reinoso", "Nelly Tapia",
  "Marco Rivas", "Ximena Corral", "Adrián Salazar", "Paty Montenegro",
  "Vicente Ruiz", "Florencia Zambrano", "Alex Cisneros", "Ruth Palacios",
  "Cristóbal León", "Emilia Andrade", "Mateo Viteri", "Clara Maldonado",
  "Iván Calle", "Daniela Mena", "Roberto Pinos", "Andrea Torres"
]

business_names = [
  "Comercial Andina S.A.",
  "Servicios Globales Cía. Ltda.",
  "Inversiones del Sol S.A.",
  "Constructora Horizonte Cía. Ltda.",
  "Alimentos Sierra Dorada S.A.",
  "Distribuidora El Faro Cía. Ltda.",
  "Tecnología y Progreso S.A.",
  "Agroexportadora Nevado Cía. Ltda.",
  "Turismo Imperial S.A.",
  "Textiles del Valle Cía. Ltda.",
  "Logística Integral S.A.",
  "Farmacéutica Aurora Cía. Ltda.",
  "Hoteles Encanto S.A.",
  "Consultores del Norte Cía. Ltda.",
  "Restaurantes Brisas S.A.",
  "Automotores Andinos Cía. Ltda.",
  "Servicios Financieros Real S.A.",
  "Panificadora Dorada Cía. Ltda.",
  "Energía Viva S.A.",
  "Transportes del Sur Cía. Ltda."
]

# Recorremos todos los LegalInfo y actualizamos legal_representative + business_name
LegalInfo.find_each.with_index do |legal_info, i|
  rep_name = representatives[i % representatives.size]
  biz_name = business_names[i % business_names.size]

  legal_info.update!(
    legal_representative: rep_name,
    business_name: biz_name
  )
end
