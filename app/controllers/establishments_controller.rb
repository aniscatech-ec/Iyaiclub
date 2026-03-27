class EstablishmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_establishment, only: %i[show edit update destroy dashboard]
  before_action :authorize_admin_or_owner!, only: %i[edit update destroy]
  layout "dashboard"

  # def index
  #   if params[:search]
  #     query = params[:search]
  #     puts "------------------------------------------------"
  #     puts query
  #     puts "------------------------------------------------"
  #     @establishments = Establishment.where(name: query)
  #   elsif params[:city].present?
  #     # Busca la ciudad por nombre y filtra sus establishments
  #     city = City.find_by(name: params[:city])
  #     @establishments = Establishment.where(city_id: city.id) if city
  #   elsif params[:country].present?
  #     # Busca el país por nombre y filtra sus establishments
  #     country = Country.find_by(name: params[:country])
  #     @establishments = Establishment.where(country: country.id) if country
  #   else
  #     @establishments = Establishment.all
  #   end
  #   # if current_user.administrador?
  #   #   # if params[:establishment].present? && Establishment.categories.key?(params[:establishment])
  #   #   #   @establishments = Establishment.where(category: Establishment.categories[params[:establishment]])
  #   #   # else
  #   #     @establishments = Establishment.all
  #   #   # end
  #   # else
  #   #   @establishments = current_user.establishments
  #   # end
  # end

  def index
    puts "================= PARAMS ================="
    puts params.inspect
    puts "=========================================="
    @establishments = Establishment.all

    # ------------------------
    # Búsqueda por nombre
    # ------------------------
    if params[:search].present?
      query = params[:search].strip
      @establishments = @establishments.where("name ILIKE ?", "%#{query}%")
    end

    # ------------------------
    # Filtrar por ciudad
    # ------------------------
    if params[:city].present?
      city = City.find_by(name: params[:city].strip)
      puts "-----------------------------CITY----------------------------------"
      @establishments = @establishments.where(city_id: city.id) if city
    end

    # ------------------------
    # Filtrar por país
    # ------------------------
    if params[:country].present?
      country = Country.find_by(name: params[:country].strip)
      @establishments = @establishments.where(country_id: country.id) if country
    end

    # ------------------------
    # Filtrar por comodidades
    # ------------------------
    if params[:amenities].present?
      puts "-----------------------------AMENITIES----------------------------------"

      amenity_ids = Amenity.where(name: params[:amenities]).pluck(:id)

      @establishments = @establishments.joins(:amenities)
                                       .where(amenities: { id: amenity_ids })
                                       .distinct
    end
    # ------------------------
    # Filtrar por fechas (opcional)
    # ------------------------
    if params[:checkin].present? && params[:checkout].present?
      checkin = Date.parse(params[:checkin]) rescue nil
      checkout = Date.parse(params[:checkout]) rescue nil

      if checkin && checkout
        # Aquí depende de cómo manejes disponibilidad. Ejemplo simplificado:
        @establishments = @establishments.select do |est|
          est.available_between?(checkin, checkout)
        end
      end
    end

    if current_user.afiliado?
      @establishments = current_user.establishments
    end
  end

  def show
    # units_controller.rb
    # @availability_events = @establishment.unit.unit_availabilities.map do |availability|
    #   {
    #     title: availability.available ? "✅ Disponible" : "❌ No disponible",
    #     start: availability.date,
    #     color: availability.available ? 'green' : 'red'
    #   }
    # end

  end

  def new
    @establishment = Establishment.new
    # @establishment = Establishment.new(user: current_user)
    #
    # if @establishment.save
    #   redirect_to establishment_establishment_steps_path(@establishment, :legal_info)
    # else
    #   flash[:error] = @establishment.errors.full_messages.to_sentence
    #   redirect_to establishments_path
    # end
  end

  # def create
  #   @establishment = Establishment.new(establishment_params)
  #   # Si es afiliado, forzamos el user_id al actual
  #   @establishment.user = current_user unless current_user.administrador?
  #
  #   if @establishment.save
  #     redirect_to @establishment, notice: 'Establecimiento creado con éxito.'
  #   else
  #     render :new
  #   end
  # end

  def create
    # @establishment = Establishment.new(establishment_params)
    # @establishment.user = current_user # si usas devise

    # @establishment = Establishment.create!(user: current_user)
    # # @establishment.user = current_user # si usas devise
    #
    # puts "CREANDO..."
    # if @establishment.save
    #   # 🚀 Redirige al wizard en el primer paso
    #   redirect_to establishment_establishment_steps_path(@establishment, :legal)
    # else
    #   render :new, status: :unprocessable_entity
    # end
    @establishment = Establishment.new(user: current_user)

    if @establishment.save
      redirect_to establishment_establishment_steps_path(@establishment, :legal_info)
    else
      flash[:error] = @establishment.errors.full_messages.to_sentence
      redirect_to establishments_path
    end
  end

  def edit
  end

  def update
    if @establishment.update(establishment_params)
      redirect_to @establishment, notice: 'Establecimiento actualizado con éxito.'
    else
      render :edit
    end
  end

  def destroy
    @establishment.destroy
    redirect_to establishments_path, notice: 'Establecimiento eliminado con éxito.'
  end

  def dashboard

  end

  def select_affiliate
    # Traemos solo los usuarios que son afiliados
    @affiliates = User.where(role: :afiliado).order(:name)

    respond_to do |format|
      format.html # render select_affiliate.html.erb
      format.json { render json: @affiliates }
    end
  end

  def choose_type
    # Aquí solo renderizamos la vista con las tarjetas
    @user_id = params[:user_id]
  end

  def create_type
    type = params[:type] # "hotel", "restaurante", etc.

    # Creamos el registro según tipo
    case type
    when "hotel"
      # hotel = Hotel.new(user: current_user)
      # Crear un establishment vacío
      est = Establishment.create(user: current_user, category: :hotel)

      # Crear el hotel vinculado
      hotel = Hotel.create(establishment: est)
      hotel.save
      puts "--------------------------------------"
      puts hotel.id
      puts current_user
      puts "-------------------------------------"

      redirect_to edit_hotel_path(hotel)

    when "restaurante"
      # est = Establishment.create(user: current_user, category: :restaurante)

      # Crear el hotel vinculado
      # restaurant = Restaurant.create(establishment: est)
      # restaurant.save
      # redirect_to edit_restaurant_path(restaurant) and return
      redirect_to new_restaurant_path and return

    when "transporte"
      redirect_to establishments_path, notice: "Módulo de Transporte próximamente disponible"

    when "agencia"
      redirect_to establishments_path, notice: "Módulo de Agencias de Viajes próximamente disponible"

    when "escapada"
      redirect_to establishments_path, notice: "Módulo de Escapadas próximamente disponible"

    when "asistencia"
      redirect_to establishments_path, notice: "Módulo de Asistencia al Usuario próximamente disponible"

    else
      redirect_to establishments_path, alert: "Tipo no válido"
    end
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:id])
  end

  def authorize_admin_or_owner!
    unless current_user.administrador? || @establishment.user == current_user
      redirect_to establishments_path, alert: 'No tienes permiso para hacer eso.'
    end
  end

  def establishment_params
    allowed = [
      :name, :description, :category, :address, :city, :country,
      :phone, :email, :website, :check_in_time, :check_out_time,
      :price_per_night, :total_rooms, :available_rooms, :latitude,
      :longitude, :rating, :policies,
      { images: [] }, # para subir múltiples imágenes
      amenity_ids: [] # para asignar amenities (array de ids)
    ]
    allowed << :user_id if current_user.administrador?

    # params.require(:establishment).permit(*allowed)
    params.require(:establishment).permit(:name, :description, :category, :city_id)

    params.require(:establishment).permit(:name,
                                          :short_description,
                                          :long_description,
                                          :category,
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
                                          amenity_ids: [])

  end

end
