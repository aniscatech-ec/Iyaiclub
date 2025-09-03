class EstablishmentStepsController < ApplicationController
  include Wicked::Wizard

  steps :legal_info, :perfil, :ubicacion, :galeria, :unidades, :politicas, :pagos, :verificacion, :revision

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
        @gallery = @establishment.galleries.create(gallery_params)
      end

      # Caso: agregar imágenes a galería existente
      if params[:gallery_image].present?
        gallery = @establishment.galleries.find(params[:gallery_image][:gallery_id])
        if params[:gallery_image][:file].present?
          params[:gallery_image][:file].each do |img|
            gallery.gallery_images.create(file: img)
          end
        end
      end

      if params[:stay_in_gallery].present?
        redirect_to wizard_path(:galeria, establishment_id: @establishment.id) and return
      end

    when :unidades
      @establishment.units.create(unit_params)
      # Si se presionó "Guardar y quedarse", redirigimos al mismo paso
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

  def establishment_params
    params.require(:establishment).permit(:name, :short_description, :long_description, :category, :amenities, :policies, :address, :city_id, :province_id, :country, :latitude, :longitude, :arrival_instructions, :currency, :service_fee, :max_discount, :refund_policy, amenity_ids: [])
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

  def unit_params
    params.require(:unit).permit(:unit_type, :capacity, :beds, :base_price, :seasonal_prices, :available)
  end

  def pricing_policy_params
    params.require(:pricing_policy).permit(:currency, :service_fee, :max_discount, :refund_policy)
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
