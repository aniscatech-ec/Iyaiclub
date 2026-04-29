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
    if @establishment
      @getaway = @establishment.getaways.build(getaway_params)
    else
      @getaway = Getaway.new(getaway_params)
    end

    if @getaway.save
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
    if @getaway.update(getaway_params)
      redirect_to @getaway, notice: 'La escapada ha sido actualizada correctamente.'
    else
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
      :experiences,
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
