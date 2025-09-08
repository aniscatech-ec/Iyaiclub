class EstablishmentStepsController < ApplicationController
  include Wicked::Wizard

  steps :legal_info, :perfil, :ubicacion, :galeria, :unidades, :politicas, :pagos, :verificacion, :revision
  before_action :merge_bed_configuration, only: [:update]

  # def show
  #   @establishment = current_user.establishment || Establishment.create(user: current_user)
  #   render_wizard
  # end

  def show
    @establishment = Establishment.find(params[:establishment_id])
    case step
    when :galeria
      # Construimos la galería en memoria
      # @gallery = @establishment.galleries.build
      # @gallery.gallery_images.build   # Permite que fields_for genere los campos de imagen
    when :verificacion
      @verification = @establishment.verification || @establishment.build_verification
    when :unidades
      @unit = @establishment.units.build

      # Construir precios por temporada si no existen
      if @unit.unit_prices.empty?
        @unit.unit_prices.build(season: "high", price: 0.0) # Temporada alta
        @unit.unit_prices.build(season: "low", price: 0.0) # Temporada baja
      end

      # Construir disponibilidad de los próximos 7 días
      if @unit.unit_availabilities.empty?
        (Date.today..Date.today + 6).each do |day|
          @unit.unit_availabilities.build(date: day, available: true)
        end
      end

    end

    render_wizard
  end

  def update
    @establishment = Establishment.find(params[:establishment_id])

    case step
    when :legal_info
      @establishment.build_legal_info(legal_info_params).save
    when :perfil, :ubicacion
      @establishment.update(establishment_params)
      # when :galeria
      #   # @establishment.galleries.create(gallery_params)
      #   @gallery = @establishment.galleries.create(gallery_params)
      #
      #   if params[:gallery][:gallery_images_attributes].present?
      #     params[:gallery][:gallery_images_attributes]["0"][:file].each do |img|
      #       @gallery.gallery_images.create(file: img)
      #     end
      #   end
    when :galeria
      # Caso: agregar nueva galería
      if params[:gallery].present?
        puts "PARAMETRO DE GALERIA PRESENTE"
        @gallery = @establishment.galleries.create(gallery_params)
      end

      # Caso: agregar imágenes a galería existente
      if params[:gallery_image].present?
        gallery = @establishment.galleries.find(params[:gallery_image][:gallery_id])

        puts "=== PARAMS RECEIVED ==="
        p params[:gallery_image][:file] # Para depuración
        puts "======================="

        # Filtramos vacíos y elementos sin nombre
        files = Array(params[:gallery_image][:file]).reject do |f|
          f.blank? || (f.respond_to?(:original_filename) && f.original_filename.blank?)
        end

        files.each_with_index do |img, index|
          puts "Procesando archivo ##{index}: #{img.inspect}"
          gallery.gallery_images.create(file: img)
        end
      end

      # Caso: marcar una imagen como portada
      if params[:make_cover].present? && params[:gallery_image_id].present?
        gi = GalleryImage.find(params[:gallery_image_id])

        # Desmarcar otras portadas de la misma galería
        gi.gallery.gallery_images.update_all(is_cover: false)

        # Marcar esta como portada
        gi.update(is_cover: true)
        redirect_to wizard_path(:galeria, establishment_id: @establishment.id), notice: "Portada actualizada" and return

      end

      if params[:stay_in_gallery].present?
        redirect_to wizard_path(:galeria, establishment_id: @establishment.id) and return
      end

      # when :unidades
      #   @establishment.units.create(unit_params)
      #   # Si se presionó "Guardar y quedarse", redirigimos al mismo paso
      #   if params[:stay_in_unit].present?
      #     redirect_to wizard_path(:unidades, establishment_id: @establishment.id) and return
      #   end
      # when :unidades
      #   @unit = @establishment.units.create(unit_params)
      #
      #   if params[:stay_in_unit].present?
      #     redirect_to wizard_path(:unidades, establishment_id: @establishment.id) and return
      #   end
    when :unidades
      # Crear la unidad normalmente con unit_params
      Rails.logger.debug "|-----------------------------------------------------|"
      Rails.logger.debug "🔎 unit_params: #{unit_params.inspect}"
      Rails.logger.debug "|-----------------------------------------------------|"
      availabilities_json = unit_params[:availabilities_json]
      # Tomamos los parámetros completos del formulario
      unit_attrs = unit_params.except(:availabilities_json) # <-- esto quita availabilities_json

      # Creamos la unidad con los campos válidos
      @unit = @establishment.units.create(unit_attrs)
      # @unit = @establishment.units.create(unit_params)

      # Procesar disponibilidad enviada desde FullCalendar
      # Ahora podemos usar availabilities_json para crear los registros de disponibilidad
      puts "|---------------------------------------------------------------------------|"
      #
      # if availabilities_json.present?
      #   puts "***********CREEANDO UNIT AVAILA**************"
      #   availabilities = JSON.parse(unit_params[:availabilities_json])
      #   @unit.unit_availabilities.destroy_all
      #   availabilities.each do |date_str|
      #     @unit.unit_availabilities.create!(date: date_str, available: true)
      #   end
      # end

      if availabilities_json.present?
        availabilities = JSON.parse(unit_params[:availabilities_json])
        availabilities.each do |a|
          @unit.unit_availabilities.find_or_initialize_by(date: a["date"]).update!(available: a["available"])
        end
      end

      if params[:stay_in_unit].present?
        redirect_to wizard_path(:unidades, establishment_id: @establishment.id) and return
      end

    when :politicas
      if @establishment.pricing_policy.present?
        @establishment.pricing_policy.update(pricing_policy_params)
      else
        @establishment.create_pricing_policy(pricing_policy_params)
      end
    when :pagos
      @payment_method = @establishment.payment_methods.create(payment_params)

      # Si se presionó "Guardar y quedarse", redirigimos al mismo paso
      if params[:stay_in_payment].present?
        redirect_to wizard_path(:pagos, establishment_id: @establishment.id) and return
      end

    when :verificacion
      @establishment.build_verification(verification_params).save
    when :revision
      # Aquí puedes guardar la confirmación final
      if params[:establishment][:confirmation] == "1"
        @establishment.update(confirmed: true) # Asegúrate de tener el campo booleano :confirmed en establishments
        flash[:notice] = "¡Registro completado con éxito!"
        # render_wizard @establishment
      else
        flash[:alert] = "Debes confirmar que la información es verdadera."
        # render_wizard
      end
    end

    render_wizard @establishment
  end

  private

  def merge_bed_configuration
    return unless params[:unit]

    keys = params[:unit].delete(:bed_configuration_keys) || []
    values = params[:unit].delete(:bed_configuration_values) || []

    bed_config = {}
    keys.each_with_index do |k, i|
      next if k.blank? || values[i].blank?
      bed_config[k] = values[i].to_i
    end

    params[:unit][:bed_configuration] = bed_config
  end

  def establishment_params
    params.require(:establishment).permit(:name, :short_description, :long_description, :category, :amenities, :address, :city_id, :province_id, :country_id, :latitude, :longitude, :arrival_instructions, :currency, :service_fee, :max_discount, :refund_policy, :check_in_time, :check_out_time, policies: [], amenity_ids: [])
  end

  def legal_info_params
    params.require(:legal_info).permit(:business_name, :legal_representative, :document_type, :document_number, :contact_email, :contact_phone)
  end

  # def gallery_params
  #   params.require(:gallery).permit(:image, :is_cover, :video_url)
  # end

  def gallery_params
    params.require(:gallery).permit(:name, gallery_images_attributes: [:file, :is_cover, :video_url])
  end

  # def unit_params
  #   params.require(:unit).permit(:unit_type, :capacity, :beds, :base_price, :seasonal_prices, :available)
  # end

  def unit_params
    params.require(:unit).permit(
      :unit_type,
      :capacity,
      :base_price,
      :availabilities_json, # <<--- agregar esto
      bed_configuration: {},
      unit_prices_attributes: [:id, :season, :price, :_destroy],
      unit_availabilities_attributes: [:id, :date, :available, :_destroy]
    )
  end

  def pricing_policy_params
    params.require(:pricing_policy).permit(:currency, :service_fee, :max_discount, refund_policy: [])
  end

  def payment_params
    params.require(:payment_method).permit(:method_type, :bank_name, :account_type, :account_number, :account_holder, :tax_id, :preferred_currency)
  end

  # def verification_params
  #   params.require(:verification).permit(:identity_document, :property_document, :selfie)
  # end
  def verification_params
    params.require(:verification).permit(:identity_document, :property_document, :selfie)
  end

  def revision_params
    params.require(:establishment).permit(:confirmation)
  end
end
