module CategoriesHelper
  def category_catalog
    [
      {
        name: "Hospedaje",
        icon: "fa-hotel",
        path: hotels_path,
        color: "var(--brand-green)",
        subtypes: hotel_subtypes,
        grouped: false
      },
      {
        name: "Gastronomia",
        icon: "fa-utensils",
        path: restaurants_path,
        color: "var(--brand-orange)",
        subtypes: restaurant_subtypes,
        grouped: true
      },
      {
        name: "Transporte",
        icon: "fa-bus",
        path: transports_path,
        color: "var(--brand-cofee)",
        subtypes: transport_subtypes,
        grouped: true
      },
      {
        name: "Alojamientos Temporales",
        icon: "fa-home",
        path: temporary_lodgings_path,
        color: "#8e44ad",
        subtypes: temporary_lodging_subtypes,
        grouped: false
      },
      {
        name: "Agencias",
        icon: "fa-map-signs",
        path: "#",
        color: "var(--brand-cofee-black)",
        subtypes: nil,
        grouped: false
      },
      {
        name: "Escapadas",
        icon: "fa-mountain-sun",
        path: getaways_path,
        color: "#e74c3c",
        subtypes: getaway_subtypes,
        grouped: false
      },
    ]
  end

  private

  def hotel_subtypes
    HotelsHelper::HOTEL_TYPE_LABELS.map do |key, label|
      { key: key, label: label, path: hotels_path(type: key) }
    end
  end

  def restaurant_subtypes
    category_labels = { "restaurante" => "Restaurante", "cafeteria" => "Cafeteria" }
    cuisine_labels = {
      "tipica" => "Tipica", "rapida" => "Rapida", "italiana" => "Italiana",
      "espanola" => "Espanola", "ecuatoriana" => "Ecuatoriana", "asiatica" => "Asiatica"
    }

    [
      {
        group: "Categoria",
        items: Restaurant::CATEGORIES.map { |c| { key: c, label: category_labels[c] || c.humanize, path: restaurants_path(type: c) } }
      },
      {
        group: "Tipo de cocina",
        items: Restaurant::CUISINE_TYPES.map { |c| { key: c, label: cuisine_labels[c] || c.humanize, path: restaurants_path(cuisine: c) } }
      }
    ]
  end

  def temporary_lodging_subtypes
    TemporaryLodgingsHelper::LODGING_TYPE_LABELS.map do |key, label|
      { key: key, label: label, path: temporary_lodgings_path(type: key) }
    end
  end

  def transport_subtypes
    sub_labels = {
      "buses" => "Buses", "busetas" => "Busetas", "transporte_mixto" => "Transporte mixto",
      "buses_turisticos" => "Buses turisticos", "taxis" => "Taxis", "rentadoras" => "Rentadoras",
      "botes" => "Botes", "yates" => "Yates", "paseos_en_bote" => "Paseos en bote", "cruceros" => "Cruceros"
    }

    [
      {
        group: "Terrestre",
        items: Transport::TERRESTRIAL_SUBCATEGORIES.map { |s| { key: s, label: sub_labels[s] || s.humanize.titleize, path: transports_path(sub: s) } }
      },
      {
        group: "Acuatico",
        items: Transport::AQUATIC_SUBCATEGORIES.map { |s| { key: s, label: sub_labels[s] || s.humanize.titleize, path: transports_path(sub: s) } }
      }
    ]
  end

  def getaway_subtypes
    sub_labels = {
      "museo" => "Museos",
      "parque_mirador" => "Parques y Miradores",
      "piscina" => "Piscinas",
      "balneario" => "Balnearios",
      "centro_recreacional" => "Centros Recreacionales",
      "parque_extremo" => "Parques Extremos",
      "senderismo" => "Senderismo",
      "camping" => "Camping"
    }

    Getaway.subcategories.keys.map do |key|
      { key: key, label: sub_labels[key] || key.humanize.titleize, path: getaways_path(sub: key) }
    end
  end
end
