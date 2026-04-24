# Script idempotente: agrega provincias y ciudades del Ecuador que falten.
# Uso desde WSL:
#   rails runner db/scripts/seed_ecuador_provinces_cities.rb

ecuador = Country.find_by!(name: "Ecuador")

PROVINCES_DATA = {
  "Azuay" => [
    "Cuenca", "Girón", "Gualaceo", "Nabón", "Paute", "Pucará", "San Fernando",
    "Santa Isabel", "Sigsig", "Oña", "Chordeleg", "El Pan", "Sevilla de Oro",
    "Guachapala", "Camilo Ponce Enríquez"
  ],
  "Bolívar" => [
    "Guaranda", "Chillanes", "Chimbo", "Echeandía", "San Miguel", "Caluma", "Las Naves"
  ],
  "Cañar" => [
    "Azogues", "Biblián", "Cañar", "La Troncal", "El Tambo", "Déleg", "Suscal"
  ],
  "Carchi" => [
    "Tulcán", "Bolívar", "Espejo", "Mira", "Montúfar", "San Pedro de Huaca"
  ],
  "Chimborazo" => [
    "Riobamba", "Alausi", "Colta", "Chambo", "Chunchi", "Guamote", "Guano",
    "Pallatanga", "Penipe", "Cumandá"
  ],
  "Cotopaxi" => [
    "Latacunga", "La Maná", "Pangua", "Pujilí", "Salcedo", "Saquisilí", "Sigchos"
  ],
  "El Oro" => [
    "Machala", "Arenillas", "Atahualpa", "Balsas", "Chilla", "El Guabo", "Huaquillas",
    "Marcabelí", "Pasaje", "Piñas", "Portovelo", "Santa Rosa", "Zaruma", "Las Lajas"
  ],
  "Esmeraldas" => [
    "Esmeraldas", "Atacames", "Eloy Alfaro", "Muisne", "Quinindé", "San Lorenzo", "Rioverde"
  ],
  "Galápagos" => [
    "Puerto Baquerizo Moreno", "Puerto Ayora", "Puerto Velasco Ibarra"
  ],
  "Guayas" => [
    "Guayaquil", "Alfredo Baquerizo Moreno", "Balao", "Balzar", "Colimes",
    "Daule", "Durán", "El Empalme", "El Triunfo", "Milagro", "Naranjal",
    "Naranjito", "Palestina", "Pedro Carbo", "Samborondón", "Santa Lucía",
    "Salitre", "San Jacinto de Yaguachi", "Playas", "Simón Bolívar",
    "Coronel Marcelino Maridueña", "Lomas de Sargentillo", "Nobol",
    "General Antonio Elizalde", "Isidro Ayora"
  ],
  "Imbabura" => [
    "Ibarra", "Antonio Ante", "Cotacachi", "Otavalo", "Pimampiro", "San Miguel de Urcuquí"
  ],
  "Loja" => [
    "Loja", "Calvas", "Catamayo", "Célica", "Chaguarpamba", "Espíndola",
    "Gonzanamá", "Macará", "Paltas", "Puyango", "Saraguro", "Sozoranga",
    "Zapotillo", "Pindal", "Quilanga", "Olmedo"
  ],
  "Los Ríos" => [
    "Babahoyo", "Baba", "Montalvo", "Puebloviejo", "Quevedo", "Urdaneta",
    "Ventanas", "Vínces", "Palenque", "Buena Fe", "Valencia", "Mocache", "Quinsaloma"
  ],
  "Manabí" => [
    "Portoviejo", "Bolívar", "Chone", "El Carmen", "Flavio Alfaro", "Jipijapa",
    "Junín", "Manta", "Montecristi", "Paján", "Pichincha", "Rocafuerte",
    "Santa Ana", "Sucre", "Tosagua", "24 de Mayo", "Pedernales", "Olmedo",
    "Puerto López", "Jama", "Jaramijó", "San Vicente"
  ],
  "Morona Santiago" => [
    "Macas", "Gualaquiza", "Huamboya", "Limón Indanza", "Logroño", "Pablo Sexto",
    "Palora", "San Juan Bosco", "Santiago", "Sucúa", "Taisha", "Tiwintza"
  ],
  "Napo" => [
    "Tena", "Archidona", "El Chaco", "Quijos", "Carlos Julio Arosemena Tola"
  ],
  "Orellana" => [
    "Francisco de Orellana", "Aguarico", "La Joya de los Sachas", "Loreto"
  ],
  "Pastaza" => [
    "Puyo", "Mera", "Santa Clara", "Arajuno"
  ],
  "Pichincha" => [
    "Quito", "Cayambe", "Mejía", "Pedro Moncayo", "Rumiñahui", "San Miguel de los Bancos",
    "Pedro Vicente Maldonado", "Puerto Quito"
  ],
  "Santa Elena" => [
    "Santa Elena", "La Libertad", "Salinas"
  ],
  "Santo Domingo de los Tsáchilas" => [
    "Santo Domingo", "La Concordia"
  ],
  "Sucumbíos" => [
    "Nueva Loja (Lago Agrio)", "Cascales", "Cuyabeno", "Gonzalo Pizarro",
    "Putumayo", "Shushufindi", "Sucumbíos"
  ],
  "Tungurahua" => [
    "Ambato", "Baños de Agua Santa", "Cevallos", "Mocha", "Patate",
    "Quero", "San Pedro de Pelileo", "Santiago de Píllaro", "Tisaleo"
  ],
  "Zamora Chinchipe" => [
    "Zamora", "Chinchipe", "Nangaritza", "Yacuambi", "Yantzaza", "El Pangui",
    "Centinela del Cóndor", "Palanda", "Paquisha"
  ]
}.freeze

puts "\n=== Seeding provincias y ciudades de Ecuador ==="
puts "País encontrado: #{ecuador.name} (id: #{ecuador.id})\n\n"

province_created = 0
province_existing = 0
city_created = 0
city_existing = 0

PROVINCES_DATA.each do |province_name, cities|
  province = Province.find_or_initialize_by(name: province_name, country: ecuador)

  if province.new_record?
    province.save!
    province_created += 1
    print "  ✚ Provincia: #{province_name}"
  else
    province_existing += 1
    print "  ✓ Provincia: #{province_name}"
  end

  new_in_province = 0
  cities.each do |city_name|
    city = City.find_or_initialize_by(name: city_name, province: province)
    if city.new_record?
      city.save!
      city_created += 1
      new_in_province += 1
    else
      city_existing += 1
    end
  end

  puts new_in_province > 0 ? " (+#{new_in_province} ciudades nuevas)" : " (sin cambios)"
end

puts "\n=== Resumen ==="
puts "  Provincias creadas:  #{province_created}"
puts "  Provincias ya tenía: #{province_existing}"
puts "  Ciudades creadas:    #{city_created}"
puts "  Ciudades ya tenía:   #{city_existing}"
puts "  TOTAL ciudades en BD: #{City.count}"
puts "=== Listo ✓ ===\n"
