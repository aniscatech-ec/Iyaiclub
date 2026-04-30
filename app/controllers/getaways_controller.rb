class GetawaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_getaway, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create_getaway!, only: [:new, :create]
  before_action :authorize_modify_getaway!, only: [:edit, :update, :destroy]
  layout "dashboard"

  def index
    if @establishment
      getaways = @establishment.getaways
    else
      getaways = Getaway.includes(:establishment)
      getaways = getaways.where(subcategory: params[:sub]) if params[:sub].present?
    end

    # Afiliados solo ven sus propias escapadas
    if current_user.afiliado?
      getaways = getaways.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @getaways = getaways
  end

  def show
  end

  def new
    if @establishment
      @getaway = @establishment.getaways.build
    else
      @getaway = Getaway.new
    end
  end

  def create
    activity_ids = Array(params.dig(:getaway, :getaway_activity_ids)).reject(&:blank?).map(&:to_i)
    amenity_ids  = Array(params.dig(:getaway, :establishment_attributes, :amenity_ids)).reject(&:blank?).map(&:to_i)

    raw = getaway_params.to_unsafe_h.deep_dup
    raw.dig("establishment_attributes")&.delete("amenity_ids")
    raw.delete("getaway_activity_ids")

    if @establishment
      @getaway = @establishment.getaways.build(raw)
    else
      @getaway = Getaway.new(raw)
    end

    if @getaway.save
      @getaway.getaway_activity_ids        = activity_ids if activity_ids.any?
      @getaway.establishment.amenity_ids   = amenity_ids  if amenity_ids.any?
      redirect_to @getaway, notice: 'La escapada ha sido creada correctamente.'
    else
      flash.now[:alert] = helpers.validation_summary_text(@getaway) || "No pudimos guardar la escapada. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @establishment = @getaway.establishment
    @establishment.build_legal_info unless @establishment.legal_info
  end

  def update
    @establishment = @getaway.establishment

    # 1. Extraer ids manualmente desde params raw (antes de cualquier conversión)
    activity_ids = Array(params.dig(:getaway, :getaway_activity_ids)).reject(&:blank?).map(&:to_i)
    amenity_ids  = Array(params.dig(:getaway, :establishment_attributes, :amenity_ids)).reject(&:blank?).map(&:to_i)

    # 2. Separar params del establishment de los del getaway
    #    Usamos to_unsafe_h para garantizar un Hash Ruby puro (no ActionController::Parameters)
    raw = getaway_params.to_unsafe_h.deep_dup

    est_attrs = raw.delete("establishment_attributes") || {}
    est_attrs.delete("amenity_ids")   # manejado manualmente abajo
    raw.delete("getaway_activity_ids") # manejado manualmente abajo

    # Solo procesar legal_info_attributes si ya existe en BD (tiene id).
    # Si no tiene id, es una instancia nueva sin datos — descartarla siempre
    # para evitar que sus validaciones de presencia bloqueen el update.
    if (li = est_attrs["legal_info_attributes"]).present? && li["id"].blank?
      est_attrs.delete("legal_info_attributes")
    end

    # Si free_entry está marcado y legal_info ya existe, saltear sus validaciones
    free_entry = raw["free_entry"].in?(["1", "true", true])
    if free_entry && @establishment.legal_info
      @establishment.legal_info.skip_validations = true
    end

    # 3. Actualizar establishment directamente
    est_ok = @establishment.update(est_attrs)

    # 4. Actualizar getaway (sin establishment_attributes ni getaway_activity_ids)
    getaway_ok = @getaway.update(raw)

    if est_ok && getaway_ok
      # 5. Asignar has_many :through — el setter llama replace() que hace save en DB
      @getaway.getaway_activity_ids      = activity_ids
      @establishment.amenity_ids         = amenity_ids
      redirect_to @getaway, notice: 'La escapada ha sido actualizada correctamente.'
    else
      Rails.logger.error "[Getaway#update] est_ok=#{est_ok} getaway_ok=#{getaway_ok}"
      Rails.logger.error "[Getaway#update] establishment errors: #{@establishment.errors.full_messages}"
      Rails.logger.error "[Getaway#update] getaway errors: #{@getaway.errors.full_messages}"
      @getaway.errors.merge!(@establishment.errors) unless est_ok
      flash.now[:alert] = helpers.validation_summary_text(@getaway) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @establishment = @getaway.establishment
    @getaway.destroy!
    redirect_to getaways_path, notice: 'La escapada fue eliminada.'
  rescue ActiveRecord::InvalidForeignKey
    redirect_to getaways_path, alert: "No se puede eliminar esta escapada porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to getaways_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_getaway
    @getaway = Getaway.includes(
      :experiences, :getaway_activities,
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def authorize_create_getaway!
    return if current_user.administrador?
    return if current_user.afiliado? && @establishment&.user_id == current_user.id

    redirect_to getaways_path, alert: "No tienes permisos para crear escapadas."
  end

  def authorize_modify_getaway!
    return if current_user.administrador?
    return if current_user.afiliado? && @getaway.establishment&.user_id == current_user.id

    redirect_to getaways_path, alert: "No tienes permisos para modificar esta escapada."
  end

  def getaway_params
    params.require(:getaway).permit(
      :subcategory, :entry_price, :free_entry, :recommendations, :rules, :establishment_id,
      getaway_activity_ids: [],
      experiences_attributes: [:id, :name, :description, :duration, :price, :requirements, :_destroy],
      establishment_attributes: [
        :id, :name, :description, :short_description, :address, :phone, :whatsapp, :email, :website,
        :country_id, :province_id, :city_id, :latitude, :longitude, :arrival_instructions,
        :opening_time, :closing_time, :status, :policies, :user_id,
        { images: [], amenity_ids: [] },
        legal_info_attributes: [
          :id, :business_name, :legal_representative, :document_type, :document_number,
          :contact_email, :contact_phone
        ]
      ]
    )
  end
end
