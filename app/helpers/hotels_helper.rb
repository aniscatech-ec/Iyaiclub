module HotelsHelper
  HOTEL_TYPE_LABELS = {
    "hotel" => "Hotel",
    "hostal" => "Hostal",
    "glamping" => "Glamping",
    "ecohotel" => "Ecohotel / Ecolodge",
    "alojamiento_temporal" => "Alojamiento temporal"
  }.freeze

  def hotel_type_label(type)
    HOTEL_TYPE_LABELS[type.to_s] || type
  end

  def hotel_type_options
    HOTEL_TYPE_LABELS.map { |k, v| [v, k] }
  end
end
