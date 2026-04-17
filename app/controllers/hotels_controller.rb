class HotelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hotel, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create_hotel!, only: [:new, :create]
  before_action :authorize_modify_hotel!, only: [:edit, :update, :destroy]
  layout "dashboard"

  def index
    hotels = Hotel.includes(:rooms, establishment: [:legal_info, :user, :country, :city, :province, :amenities, { galleries: { gallery_images: { file_attachment: :blob } } }])
    hotels = hotels.where(hotel_type: params[:type]) if params[:type].present? && Hotel.hotel_types.key?(params[:type])

    # Afiliados solo ven sus propios hoteles
    if current_user.afiliado?
      hotels = hotels.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @pagy, @hotels = pagy(hotels)
    @current_type = params[:type]
  end

  def show
  end

  # def new
  #   @hotel = Hotel.new
  #   @hotel.build_establishment.build_legal_info
  #   @hotel.establishment.galleries.build.gallery_images.build
  #   if params[:user_id].present?
  #     @affiliate = User.find(params[:user_id])
  #     @hotel.establishment.user = @affiliate
  #     @hotel.establishment.legal_info.legal_representative ||= @affiliate.name
  #   end
  # end

  def new
    @hotel = Hotel.new
    @hotel.build_establishment
    @hotel.establishment.build_legal_info
    @hotel.establishment.galleries.build

    # Asignar categoría automáticamente para hoteles
    @hotel.establishment.category = :hotel

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @hotel.establishment.user = @affiliate
      # @hotel.establishment.legal_info.legal_representative ||= @affiliate.name
    elsif current_user&.afiliado?
      # si es un afiliado que crea su propio hotel
      @hotel.establishment.user = current_user
      # @hotel.establishment.legal_info.legal_representative ||= current_user.name
    end
  end

  def edit
    @hotel.build_establishment unless @hotel.establishment
    @hotel.establishment.build_legal_info unless @hotel.establishment.legal_info
  end

  # def create
  #   @hotel = Hotel.new(hotel_params)
  #
  #   if @hotel.establishment
  #     # Solo añades valores faltantes
  #     # @hotel.establishment.user = current_user
  #     @hotel.establishment.category = :hotel
  #   else
  #     # Si no vino establishment_attributes, lo construyes
  #     # @hotel.build_establishment(user: current_user, category: :hotel)
  #     @hotel.build_establishment(category: :hotel)
  #   end
  #
  #   if @hotel.save
  #     redirect_to @hotel, notice: "Hotel creado correctamente."
  #   else
  #     render :new
  #   end
  # end
  def create
    @hotel = Hotel.new(hotel_params)

    # Asignar categoría automáticamente para hoteles si no viene del formulario
    @hotel.establishment.category = :hotel if @hotel.establishment.category.blank?

    # Asignar usuario ANTES de cualquier validación
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @hotel.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @hotel.establishment.user = current_user
    end

    if @hotel.save
      redirect_to @hotel, notice: "Hotel creado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@hotel) || "No pudimos guardar el hotel. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  # def update
  #   Rails.logger.debug "=== PARAMS RECIBIDOS ==="
  #   Rails.logger.debug params.inspect
  #   puts "=== PARAMS ==="
  #   puts params[:hotel][:establishment_attributes][:galleries_attributes].inspect
  #
  #
  #   # o si quieres algo más legible:
  #   puts JSON.pretty_generate(params.to_unsafe_h)
  #   if @hotel.update(hotel_params)
  #     redirect_to @hotel, notice: "Hotel actualizado correctamente."
  #   else
  #     render :edit
  #   end
  # end

  def update
    if @hotel.update(hotel_params)
      # Procesar uploads adicionales por galería (si el formulario envió archivos)
      if params[:gallery_uploads].present?
        params[:gallery_uploads].each do |gallery_id, files|
          next if files.blank?

          gallery = Gallery.find_by(id: gallery_id.to_i)
          next unless gallery

          files.each do |uploaded_file|
            # crea un GalleryImage por cada archivo (ajusta según tu modelo)
            gallery.gallery_images.create(file: uploaded_file)
          end
        end
      end

      redirect_to @hotel, notice: "Hotel actualizado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@hotel) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def remove_image
    gi = GalleryImage.find(params[:remove_gallery_image_id])
    gallery = gi.gallery

    gi.file.purge if gi.file.attached?
    gi.destroy

    # Si la galería ya no tiene imágenes, la borramos
    if gallery.gallery_images.empty?
      gallery.destroy
    end

    head :ok
  end

  def destroy

  end

  private

  def set_hotel
    @hotel = Hotel.includes(
      { rooms: [:room_beds, :amenities, { photo_attachment: :blob }] },
      establishment: [:legal_info, :user, :country, :city, :province, :units, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def authorize_create_hotel!
    return if current_user.administrador?
    return if current_user.afiliado?

    redirect_to hotels_path, alert: "No tienes permisos para crear hoteles."
  end

  def authorize_modify_hotel!
    return if current_user.administrador?
    return if current_user.afiliado? && @hotel.establishment&.user_id == current_user.id

    redirect_to hotels_path, alert: "No tienes permisos para modificar este hotel."
  end

  def hotel_params
    params.require(:hotel).permit(
      :stars,
      :hotel_type,
      :total_rooms,
      :available_rooms,
      :max_guests,
      rooms_attributes: [
        :id, :name, :room_type,
        :price_per_night, :guest_capacity, :description,
        :quantity, :photo, :_destroy,
        amenity_ids: [],
        room_beds_attributes: [:id, :bed_type, :quantity, :_destroy]
      ],
      establishment_attributes: [
        :user_id,
        :id,
        :name,
        :short_description,
        :long_description,
        :address,
        :phone,
        :whatsapp,
        :email,
        :website,
        :video_url,
        :city_id,
        :province_id,
        :country_id,
        :latitude,
        :longitude,
        :arrival_instructions,
        :currency,
        :service_fee,
        :max_discount,
        :refund_policy,
        :check_in_time,
        :check_out_time,
        :tipo_gestion_reserva,
        policies: [],
        amenity_ids: [],
        images: [],
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
