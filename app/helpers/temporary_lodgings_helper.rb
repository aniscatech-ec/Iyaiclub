module TemporaryLodgingsHelper
  LODGING_TYPE_LABELS = {
    "casa" => "Casa",
    "departamento" => "Departamento",
    "quinta" => "Quinta",
    "habitacion" => "Habitacion"
  }.freeze

  def lodging_type_label(type)
    LODGING_TYPE_LABELS[type.to_s] || type
  end

  def lodging_type_options
    LODGING_TYPE_LABELS.map { |k, v| [v, k] }
  end
end
