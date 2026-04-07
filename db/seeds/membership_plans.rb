# Script para crear los planes de membresía de Iyai Club
# Ejecutar con: rails runner db/seeds/membership_plans.rb

puts "🚀 Creando planes de membresía..."

# Limpiar planes existentes (opcional - comentar si no se desea)
# PlanPrice.destroy_all
# Plan.destroy_all

plans_data = [
  {
    name: "Free",
    plan_key: "free",
    description: "Ideal para usuarios nuevos o viajeros ocasionales. Acceso al portal y buscador de servicios turísticos.",
    discount_percentage: 0,
    fixed_discount: 0,
    points_earned: 1,
    dollars_per_point: 5,
    pool_visits_per_year: 0,
    pool_level: 0,
    max_pool_guests: 0,
    free_nights: 0,
    free_days: 0,
    includes_breakfast: false,
    includes_dinner: false,
    max_lodging_guests: 0,
    events_access: false,
    is_student_plan: false,
    is_active: true,
    sort_order: 0,
    features: [
      "Acceso al portal y buscador de servicios turísticos",
      "Perfil personal con historial de viajes",
      "Acumulación de puntos (1 punto por cada $5)",
      "Acceso limitado al canje de puntos",
      "Soporte por correo electrónico y WhatsApp",
      "Promociones básicas y descuentos estándar"
    ],
    prices: [] # Plan gratuito, sin precios
  },
  {
    name: "Básico",
    plan_key: "basico",
    description: "Ideal para usuarios nuevos o viajeros frecuentes. Descuentos y beneficios exclusivos.",
    discount_percentage: 20,
    fixed_discount: 0,
    points_earned: 2,
    dollars_per_point: 3,
    pool_visits_per_year: 3,
    pool_level: 1,
    max_pool_guests: 3,
    free_nights: 1,
    free_days: 2,
    includes_breakfast: false,
    includes_dinner: false,
    max_lodging_guests: 2,
    events_access: true,
    is_student_plan: false,
    is_active: true,
    sort_order: 1,
    features: [
      "Hasta 20% de descuento en hospedaje",
      "Descuentos especiales en establecimientos afiliados",
      "Piscinas nivel 1 (3 veces/año, 3 personas)",
      "1 noche y 2 días para 2 personas",
      "2 puntos por cada $3 de consumo",
      "Ingreso gratis a eventos Iyai Club",
      "Soporte por correo y WhatsApp"
    ],
    prices: [
      { duration: 1, price: 10.00, target_role: :turista },
      { duration: 6, price: 60.00, target_role: :turista },
      { duration: 12, price: 110.00, target_role: :turista }
    ]
  },
  {
    name: "Bronce",
    plan_key: "bronce",
    description: "Para viajeros que buscan más beneficios y descuentos en sus aventuras.",
    discount_percentage: 30,
    fixed_discount: 0,
    points_earned: 3,
    dollars_per_point: 2,
    pool_visits_per_year: 4,
    pool_level: 2,
    max_pool_guests: 4,
    free_nights: 2,
    free_days: 3,
    includes_breakfast: false,
    includes_dinner: false,
    max_lodging_guests: 2,
    events_access: true,
    is_student_plan: false,
    is_active: true,
    sort_order: 2,
    features: [
      "Hasta 30% de descuento en hospedaje",
      "Descuentos especiales en establecimientos afiliados",
      "Piscinas nivel 2 (4 veces/año, 4 personas)",
      "2 noches y 3 días para 2 personas",
      "3 puntos por cada $2 de consumo",
      "Ingreso gratis a eventos Iyai Club",
      "Soporte por correo y WhatsApp"
    ],
    prices: [
      { duration: 1, price: 20.00, target_role: :turista },
      { duration: 6, price: 110.00, target_role: :turista },
      { duration: 12, price: 210.00, target_role: :turista }
    ]
  },
  {
    name: "Gold",
    plan_key: "gold",
    description: "Membresía premium con los mejores descuentos y beneficios exclusivos.",
    discount_percentage: 35,
    fixed_discount: 5,
    points_earned: 5,
    dollars_per_point: 2,
    pool_visits_per_year: 5,
    pool_level: 2,
    max_pool_guests: 4,
    free_nights: 3,
    free_days: 2,
    includes_breakfast: true,
    includes_dinner: false,
    max_lodging_guests: 2,
    events_access: true,
    is_student_plan: false,
    is_active: true,
    sort_order: 3,
    features: [
      "Hasta 35% de descuento en hospedaje",
      "5% de descuento fijo adicional en cualquier temporada",
      "Descuentos especiales en establecimientos afiliados",
      "Piscinas nivel 2 (5 veces/año, 4 personas)",
      "3 noches y 2 días para 2 personas con desayuno",
      "5 puntos por cada $2 de consumo",
      "Ingreso gratis a eventos Iyai Club",
      "Soporte prioritario por correo y WhatsApp"
    ],
    prices: [
      { duration: 1, price: 25.00, target_role: :turista },
      { duration: 6, price: 140.00, target_role: :turista },
      { duration: 12, price: 260.00, target_role: :turista }
    ]
  },
  {
    name: "Platinum",
    plan_key: "platinum",
    description: "La membresía más exclusiva con máximos beneficios para toda la familia.",
    discount_percentage: 50,
    fixed_discount: 0,
    points_earned: 2,
    dollars_per_point: 1,
    pool_visits_per_year: 6,
    pool_level: 2,
    max_pool_guests: 4,
    free_nights: 3,
    free_days: 4,
    includes_breakfast: true,
    includes_dinner: true,
    max_lodging_guests: 4,
    events_access: true,
    is_student_plan: false,
    is_active: true,
    sort_order: 4,
    features: [
      "Hasta 50% de descuento en hospedaje",
      "Descuentos especiales en establecimientos afiliados",
      "Piscinas nivel 1 o 2 (6 veces/año, 4 personas)",
      "3 noches y 4 días para 2 adultos y 2 niños",
      "Incluye desayuno y cena para 2 personas",
      "2 puntos por cada $1 de consumo",
      "Ingreso gratis a eventos Iyai Club",
      "Soporte VIP por correo y WhatsApp"
    ],
    prices: [
      { duration: 1, price: 30.00, target_role: :turista },
      { duration: 6, price: 170.00, target_role: :turista },
      { duration: 12, price: 340.00, target_role: :turista }
    ]
  },
  {
    name: "Gold Estudiantil",
    plan_key: "gold_estudiantil",
    description: "Beneficios Gold especiales para estudiantes con carnet vigente.",
    discount_percentage: 35,
    fixed_discount: 0,
    points_earned: 5,
    dollars_per_point: 2,
    pool_visits_per_year: 6,
    pool_level: 2,
    max_pool_guests: 1,
    free_nights: 2,
    free_days: 3,
    includes_breakfast: true,
    includes_dinner: false,
    max_lodging_guests: 3,
    events_access: true,
    is_student_plan: true,
    is_active: true,
    sort_order: 5,
    features: [
      "Hasta 35% de descuento en hospedaje",
      "Descuentos especiales en establecimientos afiliados",
      "Piscinas nivel 1 o 2 (6 veces/año, 1 estudiante)",
      "2 noches y 3 días con desayuno para 1 adulto y 2 acompañantes",
      "5 puntos por cada $2 de consumo",
      "Ingreso gratis a eventos Iyai Club",
      "Soporte por correo y WhatsApp",
      "Requiere carnet estudiantil vigente"
    ],
    prices: [
      { duration: 1, price: 15.00, target_role: :turista },
      { duration: 6, price: 80.00, target_role: :turista },
      { duration: 12, price: 150.00, target_role: :turista }
    ]
  }
]

plans_data.each do |plan_data|
  prices = plan_data.delete(:prices)
  
  plan = Plan.find_or_initialize_by(plan_key: plan_data[:plan_key])
  plan.assign_attributes(plan_data)
  
  if plan.save
    puts "✅ Plan '#{plan.name}' creado/actualizado"
    
    prices.each do |price_data|
      plan_price = plan.plan_prices.find_or_initialize_by(
        duration: price_data[:duration],
        target_role: price_data[:target_role]
      )
      plan_price.assign_attributes(
        price: price_data[:price],
        plan_type: plan.plan_key
      )
      
      if plan_price.save
        puts "   💰 Precio: $#{price_data[:price]} / #{price_data[:duration]} mes(es)"
      else
        puts "   ❌ Error en precio: #{plan_price.errors.full_messages.join(', ')}"
      end
    end
  else
    puts "❌ Error creando plan '#{plan_data[:name]}': #{plan.errors.full_messages.join(', ')}"
  end
end

puts ""
puts "📊 Resumen:"
puts "   Planes creados: #{Plan.count}"
puts "   Precios creados: #{PlanPrice.count}"
puts ""
puts "✨ ¡Proceso completado!"
