# app/controllers/restaurants_controller.rb
class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    @restaurants = Restaurant.all
  end

  def show
  end

  # def new
  #   @restaurant = Restaurant.new
  #   @restaurant.build_establishment.build_legal_info
  #   @restaurant.establishment.galleries.build.gallery_images.build
  # end

  def new
    @restaurant = Restaurant.new
    @restaurant.build_establishment.build_legal_info
    @restaurant.establishment.galleries.build.gallery_images.build

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @restaurant.establishment.user = @affiliate
    elsif current_user&.afiliado?
      # si es un afiliado que crea su propio hotel
      @restaurant.establishment.user = current_user
    end
  end

  # def create
  #   @restaurant = Restaurant.new(restaurant_params)
  #
  #   if @restaurant.establishment
  #     # Solo añades valores faltantes
  #     @restaurant.establishment.user = current_user
  #     @restaurant.establishment.category = :restaurante
  #   else
  #     # Si no vino establishment_attributes, lo construyes
  #     @restaurant.build_establishment(user: current_user, category: :restaurante)
  #   end
  #
  #
  #   if @restaurant.save
  #     redirect_to @restaurant, notice: "Restaurante creado correctamente."
  #   else
  #     render :new
  #   end
  # end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    if @restaurant.establishment
      @restaurant.establishment.category = :restaurante
    else
      @restaurant.build_establishment(category: :restaurante)
    end

    # 👇 Aquí seteamos el user siempre en el servidor
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @restaurant.establishment.user = @affiliate
    elsif current_user&.afiliado?
      @restaurant.establishment.user = current_user
    end

    if @restaurant.save
      redirect_to @restaurant, notice: "Restaurante creado correctamente."
    else
      render :new
    end
  end

  def edit
    @restaurant.build_establishment unless @restaurant.establishment
    @restaurant.establishment.build_legal_info unless @restaurant.establishment.legal_info
  end

  # def update
  #   if @restaurant.update(restaurant_params)
  #     redirect_to @restaurant, notice: "Restaurante actualizado correctamente."
  #   else
  #     render :edit
  #   end
  # end

  def update
    if @restaurant.update(restaurant_params)
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

      redirect_to @restaurant, notice: "Restaurante actualizado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @restaurant.destroy
    redirect_to restaurants_path, notice: "Restaurante eliminado."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params_1
    params.require(:restaurant).permit(:cuisine_type, :category)
  end

  def restaurant_params
    params.require(:restaurant).permit(
      :cuisine_type, :category,
      establishment_attributes: [
        :user_id,
        :id,
        :name, # Nombre público
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
          :id,
          :business_name, # Razón social
          :document_number, # RUC
          :legal_representative, # Responsable / gerente
          :contact_email, # Email
          :contact_phone # Teléfono
        ],
        galleries_attributes: [
          :id, :name, :_destroy,
          gallery_images_attributes: [:id, :file, :_destroy]
        ]

      ]
    )
  end
end
