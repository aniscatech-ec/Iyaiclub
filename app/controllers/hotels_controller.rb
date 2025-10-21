class HotelsController < ApplicationController
  before_action :set_hotel, only: [:show, :edit, :update, :destroy]
  # layout "dashboard"
  before_action :authenticate_user!, except: [:index, :show, :search_results]

  # def index
  #   @hotels = Hotel.all
  # end

  # def index
  #   # @hotels = Hotel.all
  #   @hotels = Hotel.includes(establishment: [:amenities, :city, :country])
  #
  #   # ------------------------
  #   # Búsqueda por nombre
  #   # ------------------------
  #   if params[:search].present?
  #     query = params[:search].strip
  #     @hotels = @hotels.where("name ILIKE ?", "%#{query}%")
  #   end
  #
  #   # ------------------------
  #   # Filtrar por ciudad
  #   # ------------------------
  #   if params[:city].present?
  #     city = City.find_by(name: params[:city].strip)
  #     if city
  #       @hotels = @hotels.joins(:establishment).where(establishments: { city_id: city.id })
  #     end
  #   end
  #
  #
  #   # ------------------------
  #   # Filtrar por país
  #   # ------------------------
  #   if params[:country].present?
  #     country = Country.find_by(name: params[:country].strip)
  #     @hotels = @hotels.where(country_id: country.id) if country
  #   end
  #
  #   # ------------------------
  #   # Filtrar por comodidades
  #   # ------------------------
  #   # if params[:amenities].present?
  #   #   amenity_ids = Amenity.where(name: params[:amenities]).pluck(:id)
  #   #   @hotels = @hotels.joins(:amenities)
  #   #                    .where(amenities: { id: amenity_ids })
  #   #                    .distinct
  #   # end
  #
  #   # if params[:amenities].present?
  #   #   amenity_ids = Amenity.where(name: params[:amenities]).pluck(:id)
  #   #
  #   #   # Accedemos a amenities a través de establishment
  #   #   @hotels = @hotels.joins(establishment: :amenities)
  #   #                    .where(amenities: { id: amenity_ids })
  #   #                    .distinct
  #   # end
  #   # if params[:amenities].present?
  #   #   puts "=================== PARAMS DE AMENITIES ==================="
  #   #   puts params[:amenities].inspect
  #   #   puts "============================================================"
  #   #
  #   #   amenity_ids = Amenity.where(name: params[:amenities]).pluck(:id)
  #   #
  #   #   puts "=================== AMENITY IDS ==================="
  #   #   puts amenity_ids.inspect
  #   #   puts "==================================================="
  #   #
  #   #   # Accedemos a amenities a través de establishment
  #   #   @hotels = @hotels.joins(establishment: :amenities)
  #   #                    .where(amenities: { id: amenity_ids })
  #   #                    .distinct
  #   # end
  #
  #
  #   if params[:min_price].present? && params[:max_price].present?
  #     min = params[:min_price].to_i
  #     max = params[:max_price].to_i
  #
  #     @hotels = @hotels.joins(:establishment)
  #                      .where(establishments: { price_per_night: min..max })
  #   end
  #
  #
  #   if params[:amenities].present?
  #     amenity_ids = Array(params[:amenities]).map(&:to_i)
  #
  #     if amenity_ids.any?
  #       establishment_ids = Establishment.joins(:amenities)
  #                                        .where(amenities: { id: amenity_ids })
  #                                        .group(:id)
  #                                        .having("COUNT(DISTINCT amenities.id) = ?", amenity_ids.size)
  #                                        .pluck(:id)
  #       @hotels = @hotels.joins(:establishment).where(establishments: { id: establishment_ids })
  #     else
  #       @hotels = @hotels.none
  #     end
  #   end
  #
  #   if request.xhr?
  #     render partial: "hotels/hotels_list", locals: { hotels: @hotels }
  #   else
  #     render :index
  #   end
  #
  #
  #   # ------------------------
  #   # Filtrar por fechas (opcional)
  #   # ------------------------
  #   if params[:checkin].present? && params[:checkout].present?
  #     checkin = Date.parse(params[:checkin]) rescue nil
  #     checkout = Date.parse(params[:checkout]) rescue nil
  #     if checkin && checkout
  #       @hotels = @hotels.select { |hotel| hotel.available_between?(checkin, checkout) }
  #     end
  #   end
  #
  #   # ------------------------
  #   # Filtrar por usuario afiliado (opcional)
  #   # ------------------------
  #   if current_user.afiliado?
  #     @hotels = current_user.establishments.where(category: "hotel")
  #   end
  #
  #
  # end

  def index
    puts "-------------------------------------------------------------"
    puts "-------------------------REALIZANDO PETICION GET----------------------------"
    puts params.inspect
    puts "-------------------------------------------------------------"
    @cities = City.all
    @amenities = Amenity.all

    # Incluimos establishment para acceder a sus atributos
    @hotels = Hotel.includes(establishment: [:city, :amenities])

    # 🔹 Filtros dinámicos
    if params[:city].present?
      @hotels = @hotels.joins(:establishment).where(establishments: { city_id: params[:city] })
    end

    # Filtro por estrellas
    if params[:stars].present?
      @hotels = @hotels.where(stars: params[:stars].to_i)
    end

    if params[:hotel_type].present?
      @hotels = @hotels.where(hotel_type: params[:hotel_type])
    end

    if params[:min_price].present? && params[:max_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where(establishments: { price_per_night: params[:min_price]..params[:max_price] })
    elsif params[:min_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where("establishments.price_per_night >= ?", params[:min_price])
    elsif params[:max_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where("establishments.price_per_night <= ?", params[:max_price])
    end

    if params[:amenities].present?
      hotel_ids = @hotels.joins(establishment: :amenities)
                         .where(amenities: { id: params[:amenities] })
                         .group("hotels.id")
                         .having("COUNT(DISTINCT amenities.id) = ?", params[:amenities].size)
                         .pluck(:id)
      @hotels = @hotels.where(id: hotel_ids)
    end

    if user_signed_in? && current_user.administrador?

    else
      @hotels = @hotels.page(params[:page]).per(9)

    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search_results
    puts "-------------------------------------------------------------"
    puts "-------------------------REALIZANDO PETICION GET----------------------------"
    puts params.inspect
    puts "-------------------------------------------------------------"
    @cities = City.all
    @amenities = Amenity.all

    # Incluimos establishment para acceder a sus atributos
    @hotels = Hotel.includes(establishment: [:city, :amenities])

    # 🔹 Filtros dinámicos
    # if params[:city].present?
    #   @hotels = @hotels.joins(:establishment).where(establishments: { city_id: params[:city] })
    # end

    if params[:city].present?
      if params[:city].to_s.match?(/^\d+$/)
        # Si es un número → úsalo como ID
        puts "ID*******************************"
        @hotels = @hotels.joins(:establishment).where(establishments: { city_id: params[:city] })
        @city_name = City.find_by(id: params[:city])&.name
      else
        # Si es texto → buscar por nombre
        # Si es un texto => usar
        puts "TEXTO *******************************"

        @city_name = params[:city]
        city = City.find_by("LOWER(name) = ?", params[:city].downcase)
        if city
          @hotels = @hotels.joins(:establishment).where(establishments: { city_id: city.id })
        else
          @hotels = @hotels.none
        end
      end
    end

    # Filtro por estrellas
    if params[:stars].present?
      @hotels = @hotels.where(stars: params[:stars].to_i)
    end

    if params[:hotel_type].present?
      @hotels = @hotels.where(hotel_type: params[:hotel_type])
    end

    if params[:min_price].present? && params[:max_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where(establishments: { price_per_night: params[:min_price]..params[:max_price] })
    elsif params[:min_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where("establishments.price_per_night >= ?", params[:min_price])
    elsif params[:max_price].present?
      @hotels = @hotels.joins(:establishment)
                       .where("establishments.price_per_night <= ?", params[:max_price])
    end

    if params[:amenities].present?
      hotel_ids = @hotels.joins(establishment: :amenities)
                         .where(amenities: { id: params[:amenities] })
                         .group("hotels.id")
                         .having("COUNT(DISTINCT amenities.id) = ?", params[:amenities].size)
                         .pluck(:id)
      @hotels = @hotels.where(id: hotel_ids)
    end

    @hotels = @hotels.page(params[:page]).per(9)

    respond_to do |format|
      format.html
      format.js
    end
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
    @hotel.build_establishment.build_legal_info
    @hotel.establishment.galleries.build.gallery_images.build

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

    if @hotel.establishment
      @hotel.establishment.category = :hotel
    else
      @hotel.build_establishment(category: :hotel)
    end

    # 👇 Aquí seteamos el user siempre en el servidor
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @hotel.establishment.user = @affiliate
    elsif current_user&.afiliado?
      @hotel.establishment.user = current_user
    end

    if @hotel.save
      redirect_to @hotel, notice: "Hotel creado correctamente."
    else
      render :new
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
      render :edit
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
    @hotel = Hotel.find(params[:id])
  end

  def hotel_params
    params.require(:hotel).permit(
      :stars,
      :hotel_type,
      establishment_attributes: [
        :user_id,
        :id, # <-- para que no te bote el warning
        :name,
        :short_description,
        :long_description,
        :amenities,
        :address,
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
        :video,
        :video_url,
        policies: [],
        amenity_ids: [],
        legal_info_attributes: [
          :id, # <-- también aquí
          :business_name,
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
