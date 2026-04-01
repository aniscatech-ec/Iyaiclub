class TransportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transport, only: [:show, :edit, :update, :destroy]
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
    @pagy, @transports = pagy(transports)
    @current_type = params[:type] || params[:sub]
  end

  def show
  end

  def new
    @transport = Transport.new
    @transport.build_establishment.build_legal_info
    @transport.establishment.galleries.build.gallery_images.build

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @transport.establishment.user = @affiliate
    elsif current_user&.afiliado?
      @transport.establishment.user = current_user
    end
  end

  def edit
    @transport.build_establishment unless @transport.establishment
    @transport.establishment.build_legal_info unless @transport.establishment.legal_info
  end

  def create
    @transport = Transport.new(transport_params)

    if @transport.establishment
      @transport.establishment.category = :transporte
    else
      @transport.build_establishment(category: :transporte)
    end

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @transport.establishment.user = @affiliate
    elsif current_user&.afiliado?
      @transport.establishment.user = current_user
    end

    if @transport.save
      redirect_to @transport, notice: "Transporte creado correctamente."
    else
      flash.now[:alert] = "No pudimos guardar el transporte. Por favor revisa los campos."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transport.update(transport_params)
      redirect_to @transport, notice: "Transporte actualizado correctamente."
    else
      flash.now[:alert] = "No pudimos guardar los cambios. Por favor revisa los campos."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transport.establishment.destroy
    redirect_to transports_path, notice: "Transporte eliminado correctamente."
  end

  private

  def set_transport
    @transport = Transport.includes(
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def transport_params
    params.require(:transport).permit(
      :transport_type,
      :subcategory,
      :capacity,
      :service_description,
      :price_range,
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
