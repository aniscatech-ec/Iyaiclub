class TravelAgenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_travel_agency, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create_travel_agency!, only: [:new, :create]
  before_action :authorize_modify_travel_agency!, only: [:edit, :update, :destroy]
  layout "dashboard"

  def index
    travel_agencies = TravelAgency.includes(establishment: [:legal_info, :user, :country, :city, :province, :amenities, { galleries: { gallery_images: { file_attachment: :blob } } }])

    if current_user.afiliado?
      travel_agencies = travel_agencies.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @pagy, @travel_agencies = pagy(travel_agencies)
  end

  def show
    @tour_packages = @travel_agency.tour_packages
  end

  def new
    @travel_agency = TravelAgency.new
    @travel_agency.build_establishment
    @travel_agency.establishment.build_legal_info
    @travel_agency.establishment.category = :agencia

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @travel_agency.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @travel_agency.establishment.user = current_user
    end
  end

  def create
    @travel_agency = TravelAgency.new(travel_agency_params)

    # El EstablishmentTypes de category puede no tener 'travel_agency' exactamente, 
    # asumiendo categoria general o :agencia según el enum
    @travel_agency.establishment.category = "agencia" if @travel_agency.establishment.category.blank?

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @travel_agency.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @travel_agency.establishment.user = current_user
    end

    if @travel_agency.save
      process_new_gallery_uploads(@travel_agency.establishment)
      redirect_to @travel_agency, notice: "Agencia turística creada correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@travel_agency) || "No pudimos guardar la agencia. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @travel_agency.build_establishment unless @travel_agency.establishment
    @travel_agency.establishment.build_legal_info unless @travel_agency.establishment.legal_info
  end

  def update
    if @travel_agency.update(travel_agency_params)
      process_existing_gallery_uploads(@travel_agency.establishment)
      process_new_gallery_uploads(@travel_agency.establishment)
      redirect_to @travel_agency, notice: "Agencia turística actualizada correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@travel_agency) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @travel_agency.establishment.destroy!
    redirect_to travel_agencies_path, notice: "Agencia turística eliminada."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to travel_agencies_path, alert: "No se puede eliminar esta agencia porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to travel_agencies_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_travel_agency
    @travel_agency = TravelAgency.includes(
      :tour_packages,
      establishment: [:legal_info, :user, :country, :city, :province, :units, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def process_existing_gallery_uploads(establishment)
    return unless params[:gallery_uploads].present?
    params[:gallery_uploads].each do |gallery_id, files|
      next if files.blank?
      gallery = establishment.galleries.find_by(id: gallery_id.to_i)
      next unless gallery
      Array(files).each { |f| gallery.gallery_images.create(file: f) if f.respond_to?(:read) }
    end
  end

  def process_new_gallery_uploads(establishment)
    return unless params[:new_gallery_uploads].present?
    params[:new_gallery_uploads].each do |_key, data|
      files = Array(data[:files]).select { |f| f.respond_to?(:read) }
      next if files.empty?
      gallery = establishment.galleries.create(name: data[:name].presence || "Galería")
      files.each { |file| gallery.gallery_images.create(file: file) }
    end
  end

  def authorize_create_travel_agency!
    return if current_user.administrador?
    return if current_user.afiliado?

    redirect_to travel_agencies_path, alert: "No tienes permisos para crear agencias turísticas."
  end

  def authorize_modify_travel_agency!
    return if current_user.administrador?
    return if current_user.afiliado? && @travel_agency.establishment&.user_id == current_user.id

    redirect_to travel_agencies_path, alert: "No tienes permisos para modificar esta agencia."
  end

  def travel_agency_params
    params.require(:travel_agency).permit(
      :subcategory,
      tour_packages_attributes: [
        :id, :name, :package_type, :destination, :days, :nights,
        :min_group, :max_group, :difficulty, :departure_point,
        :price, :member_price, :description, :itinerary,
        :includes, :excludes, :next_departures, :season, :duration,
        :includes_transport, :includes_food, :includes_lodging, :includes_guide,
        :active, :cover_photo, :_destroy
      ],
      establishment_attributes: [
        :user_id, :id, :name, :short_description, :description, :long_description,
        :address, :phone, :whatsapp, :email, :website, :status,
        :city_id, :province_id, :country_id, :latitude, :longitude,
        :arrival_instructions, :currency, :service_fee, :max_discount,
        :refund_policy, :check_in_time, :check_out_time, :opening_time, :closing_time,
        :video, :video_url, policies: [], amenity_ids: [], images: [],
        legal_info_attributes: [
          :id, :business_name, :document_type, :document_number,
          :legal_representative, :contact_email, :contact_phone
        ],
        galleries_attributes: [
          :id, :name, :_destroy,
          gallery_images_attributes: [:id, :file, :_destroy]
        ]
      ]
    )
  end
end
