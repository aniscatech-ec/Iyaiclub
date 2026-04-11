class TransportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transport, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create!, only: [:new, :create]
  before_action :authorize_modify!, only: [:edit, :update, :destroy]
  layout "dashboard"

  def index
    transports = Transport.includes(
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    )
    if params[:type].present? && Transport::TRANSPORT_TYPES.include?(params[:type])
      transports = transports.where(transport_type: params[:type])
    elsif params[:sub].present? && Transport::ALL_SUBCATEGORIES.include?(params[:sub])
      transports = transports.where(subcategory: params[:sub])
    end

    # Afiliados solo ven sus propios transportes
    if current_user.afiliado?
      transports = transports.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @pagy, @transports = pagy(transports)
    @current_type = params[:type] || params[:sub]
  end

  def show
  end

  def new
    @transport = Transport.new
    @transport.build_establishment
    @transport.establishment.build_legal_info
    @transport.establishment.galleries.build.gallery_images.build

    # Asignar categoría automáticamente para transportes
    @transport.establishment.category = :transporte

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @transport.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @transport.establishment.user = current_user
    end
  end

  def edit
    @transport.build_establishment unless @transport.establishment
    @transport.establishment.build_legal_info unless @transport.establishment.legal_info
  end

  def create
    @transport = Transport.new(transport_params)

    # Asignar categoría automáticamente para transportes si no viene del formulario
    @transport.establishment.category = :transporte if @transport.establishment.category.blank?

    # Asignar usuario ANTES de cualquier validación
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @transport.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @transport.establishment.user = current_user
    end

    if @transport.save
      redirect_to @transport, notice: "Transporte creado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@transport) || "No pudimos guardar el transporte. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transport.update(transport_params)
      redirect_to @transport, notice: "Transporte actualizado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@transport) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transport.establishment.destroy!
    redirect_to transports_path, notice: "Transporte eliminado correctamente."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to transports_path, alert: "No se puede eliminar este transporte porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to transports_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_transport
    @transport = Transport.includes(
      :vehicles,
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def authorize_create!
    return if current_user.administrador?
    return if current_user.afiliado?
    redirect_to transports_path, alert: "No tienes permisos para crear transportes."
  end

  def authorize_modify!
    return if current_user.administrador?
    return if current_user.afiliado? && @transport.establishment&.user_id == current_user.id
    redirect_to transports_path, alert: "No tienes permisos para acceder a este transporte."
  end

  def transport_params
    params.require(:transport).permit(
      :transport_type,
      :subcategory,
      :capacity,
      :service_description,
      :price_range,
      :total_vehicles,
      :available_vehicles,
      :routes,
      :service_frequency,
      :operating_area,
      vehicles_attributes: [:id, :name, :description, :price_per_day, :conditions, :photo, :_destroy],
      establishment_attributes: [
        :id,
        :user_id,
        :name,
        :description,
        :short_description,
        :long_description,
        :address,
        :phone,
        :whatsapp,
        :email,
        :website,
        :city_id,
        :province_id,
        :country_id,
        :latitude,
        :longitude,
        :arrival_instructions,
        :opening_time,
        :closing_time,
        :status,
        :video,
        :video_url,
        :rating,
        images: [],
        policies: [],
        amenity_ids: [],
        legal_info_attributes: [
          :id,
          :business_name,
          :document_type,
          :document_number,
          :legal_representative,
          :contact_email,
          :contact_phone
        ],
        galleries_attributes: [
          :id, :name, :_destroy,
          gallery_images_attributes: [:id, :file, :_destroy]
        ]
      ]
    )
  end
end
