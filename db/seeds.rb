# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

# Crear 50 afiliados
50.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: "123456",
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone,
    role: :afiliado,
    country_id: Country.all.sample&.id,
    city_id: City.all.sample&.id,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
    terms_accepted: true,
    marketing_consent: [true, false].sample
  )
end

# Crear 30 turistas
30.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: "123456",
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone,
    role: :turista,
    country_id: Country.all.sample&.id,
    city_id: City.all.sample&.id,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
    terms_accepted: true,
    marketing_consent: [true, false].sample
  )
end
