# frozen_string_literal: true

# Helper DRY para recolectar y mostrar errores de validación
# de un modelo principal y TODAS sus asociaciones anidadas.
#
# Se usa en los formularios de establecimientos (hoteles, restaurantes,
# transportes, alojamientos temporales, escapadas, hospedajes) y en sus
# flash messages, para mostrarle al usuario EXACTAMENTE qué campo está fallando.
module ValidationErrorsHelper
  # Asociaciones que NO recorremos para evitar recursión infinita o ruido.
  SKIP_ASSOCIATIONS = %w[
    user country province city
    images file file_attachment file_blob
    amenities establishment_amenities
  ].freeze

  # Secciones legibles para cada modelo anidado
  SECTION_LABELS = {
    "Hotel" => "Datos del hotel",
    "Restaurant" => "Datos del restaurante",
    "Transport" => "Datos del transporte",
    "TemporaryLodging" => "Datos del alojamiento temporal",
    "Getaway" => "Datos de la escapada",
    "Lodging" => "Datos del hospedaje",
    "Establishment" => "Datos del establecimiento",
    "LegalInfo" => "Datos legales y contacto",
    "Gallery" => "Galería de imágenes",
    "GalleryImage" => "Imagen de galería",
    "Unit" => "Unidad / habitación",
    "Vehicle" => "Vehículo",
    "Menu" => "Menú",
    "MenuItem" => "Ítem de menú",
    "PricingPolicy" => "Política de precios",
    "PaymentMethod" => "Método de pago"
  }.freeze

  # Recolecta TODOS los errores de un record y sus asociaciones anidadas.
  # Devuelve un array de hashes: [{ section:, field:, message:, full: }, ...]
  def collect_nested_errors(record, visited = Set.new)
    return [] if record.blank?
    return [] if visited.include?(record.object_id)

    visited << record.object_id
    errors = []

    # 1. Errores del propio record
    if record.respond_to?(:errors) && record.errors.any?
      section = SECTION_LABELS[record.class.name] || record.class.name.underscore.humanize
      record.errors.each do |err|
        # Ignorar errores "asociación inválida" — los mostramos al recorrer la asociación
        next if err.message.to_s.match?(/is invalid|no es válido|es inválid/i) && association_attribute?(record, err.attribute)

        field_label = human_field_label(record, err.attribute)
        errors << {
          section: section,
          field: field_label,
          message: err.message,
          full: "#{field_label}: #{err.message}"
        }
      end
    end

    # 2. Recorrer asociaciones anidadas cargadas
    if record.class.respond_to?(:reflect_on_all_associations)
      record.class.reflect_on_all_associations.each do |assoc|
        next if SKIP_ASSOCIATIONS.include?(assoc.name.to_s)

        case assoc.macro
        when :has_one, :belongs_to
          next unless record.association(assoc.name).loaded? || record.send(assoc.name).present?
          child = record.send(assoc.name) rescue nil
          errors.concat(collect_nested_errors(child, visited)) if child.present?
        when :has_many
          next unless record.association(assoc.name).loaded?
          children = record.send(assoc.name) rescue []
          children.each do |child|
            next if child.marked_for_destruction?
            errors.concat(collect_nested_errors(child, visited))
          end
        end
      end
    end

    errors
  end

  # Texto corto para flash: "Faltan 3 campos obligatorios: X, Y, Z"
  def validation_summary_text(record, limit: 5)
    all_errors = collect_nested_errors(record)
    return nil if all_errors.empty?

    count = all_errors.size
    fields = all_errors.first(limit).map { |e| e[:field] }.uniq
    extra = count > limit ? " y #{count - limit} más" : ""

    if count == 1
      "Falta 1 dato obligatorio: #{fields.first} (#{all_errors.first[:message]})"
    else
      "Faltan #{count} datos obligatorios: #{fields.join(', ')}#{extra}"
    end
  end

  # Renderiza el partial compartido con todos los errores agrupados.
  def render_validation_errors(record)
    all_errors = collect_nested_errors(record)
    return nil if all_errors.empty?

    render partial: "shared/validation_errors", locals: { errors_list: all_errors }
  end

  private

  # Devuelve la etiqueta humanizada del campo, usando human_attribute_name.
  def human_field_label(record, attribute)
    return "General" if attribute.to_s == "base"

    # Eliminar sufijo _id para mostrar "País" en vez de "País Id"
    attr = attribute.to_s.sub(/_id\z/, "")
    record.class.human_attribute_name(attr)
  rescue
    attribute.to_s.humanize
  end

  # Comprueba si el atributo es en realidad una asociación (para ignorar "es inválido")
  def association_attribute?(record, attribute)
    return false unless record.class.respond_to?(:reflect_on_all_associations)
    record.class.reflect_on_all_associations.any? { |a| a.name.to_s == attribute.to_s }
  end
end
