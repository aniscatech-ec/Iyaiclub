module ApplicationHelper
  include Pagy::Frontend

  DEFAULT_COUNTRY_CODE = "593" # Ecuador

  def whatsapp_link(phone, message = nil, country_code: DEFAULT_COUNTRY_CODE)
    return nil if phone.blank?

    sanitized = phone.to_s.gsub(/[^\d+]/, "")
    sanitized = sanitized.delete("+")

    # Si el número empieza con 0 (formato local), reemplazar por código de país
    if sanitized.start_with?("0")
      sanitized = country_code + sanitized[1..]
    # Si tiene solo 9-10 dígitos y no empieza con código de país, agregar código
    elsif sanitized.length <= 10 && !sanitized.start_with?(country_code)
      sanitized = country_code + sanitized
    end

    url = "https://wa.me/#{sanitized}"
    url += "?text=#{ERB::Util.url_encode(message)}" if message.present?
    url
  end

  def ticket_status_badge_class(status)
    case status.to_s
    when 'activo' then 'bg-success'
    when 'usado' then 'bg-secondary'
    when 'cancelado' then 'bg-danger'
    when 'reservado' then 'bg-warning text-dark'
    else 'bg-secondary'
    end
  end

  def event_status_badge(status)
    case status.to_s
    when 'borrador' then 'bg-secondary'
    when 'publicado' then 'bg-success'
    when 'cancelado' then 'bg-danger'
    when 'finalizado' then 'bg-dark'
    else 'bg-secondary'
    end
  end
end
