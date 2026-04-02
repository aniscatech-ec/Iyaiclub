# app/helpers/establishments_helper.rb
module EstablishmentsHelper
  require "cgi"
  require "uri"

  # Devuelve un hash con :type y :src o nil si no reconoce la URL
  def video_embed_info(url)
    return nil if url.blank?

    uri = URI.parse(url) rescue nil
    return nil unless uri

    # Enlace directo a mp4/webm/ogg -> usar video_tag
    if uri.path =~ /\.(mp4|webm|ogg)(\?.*)?$/i
      return { type: :file, src: url }
    end

    host = uri.host.to_s.downcase

    # YouTube
    if host.include?("youtube.com") || host.include?("youtu.be") || host.include?("youtube-nocookie.com")
      m = url.match(%r{(?:youtu\.be\/|youtube(?:-nocookie)?\.com\/(?:watch\?v=|embed\/|v\/|shorts\/))([A-Za-z0-9_-]{5,})})
      if m && m[1]
        vid = m[1]
        return { type: :youtube, src: "https://www.youtube.com/embed/#{vid}" }
      end
      params = CGI.parse(uri.query.to_s) rescue {}
      if params["v"].present?
        return { type: :youtube, src: "https://www.youtube.com/embed/#{params['v'].first}" }
      end
    end

    # Vimeo
    if host.include?("vimeo.com")
      m = url.match(%r{vimeo\.com/(?:video/)?([0-9]+)})
      if m && m[1]
        vid = m[1]
        return { type: :vimeo, src: "https://player.vimeo.com/video/#{vid}" }
      end
    end

    nil
  end

  # Output seguro: iframe o video_tag o un link si no se reconoce
  def embed_video_tag_from_url(url, options = {})
    info = video_embed_info(url)
    return nil unless info

    case info[:type]
    when :file
      video_tag(info[:src], controls: true, preload: "metadata", **options)
    when :youtube, :vimeo
      src = info[:src]
      params = options.delete(:params)
      src = "#{src}#{params.present? ? "?#{params.to_query}" : ""}"

      content_tag(:div, class: "ratio ratio-16x9 mb-3") do
        tag.iframe(
          src: src,
          frameborder: 0,
          allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share",
          allowfullscreen: true,
          **options
        )
      end
    else
      nil
    end
  end

  # Devuelve la ruta de edición específica según la categoría del establecimiento
  def edit_specific_establishment_path(est)
    case est.category
    when "hotel"
      est.hotel ? edit_hotel_path(est.hotel) : edit_establishment_path(est)
    when "restaurante"
      est.restaurant ? edit_restaurant_path(est.restaurant) : edit_establishment_path(est)
    when "transporte"
      est.transport ? edit_transport_path(est.transport) : edit_establishment_path(est)
    when "alojamiento_temporal"
      est.temporary_lodging ? edit_temporary_lodging_path(est.temporary_lodging) : edit_establishment_path(est)
    else
      edit_establishment_path(est)
    end
  end

  def establishment_type_label(type)
    {
      "hotel" => "Hotel",
      "restaurante" => "Restaurante",
      "transporte" => "Transporte",
      "agencia" => "Agencia de Viajes",
      "escapada" => "Escapadas",
      "asistencia" => "Asistencia",
      "alojamiento_temporal" => "Alojamiento Temporal"
    }[type] || type
  end
end
