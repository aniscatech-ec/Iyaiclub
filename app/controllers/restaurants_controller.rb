# app/controllers/restaurants_controller.rb
class RestaurantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create_restaurant!, only: [:new, :create]
  before_action :authorize_modify_restaurant!, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    restaurants = Restaurant.includes(establishment: [:legal_info, :user, :country, :city, :province, :amenities, { galleries: { gallery_images: { file_attachment: :blob } } }])
    if params[:type].present? && Restaurant::CATEGORIES.include?(params[:type])
      restaurants = restaurants.where(category: params[:type])
    elsif params[:cuisine].present? && Restaurant::CUISINE_TYPES.include?(params[:cuisine])
      restaurants = restaurants.where(cuisine_type: params[:cuisine])
    end
    # Afiliados solo ven sus propios restaurantes
    if current_user.afiliado?
      restaurants = restaurants.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @pagy, @restaurants = pagy(restaurants)
    @current_type = params[:type] || params[:cuisine]
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
    @restaurant.build_establishment
    @restaurant.establishment.build_legal_info
    @restaurant.establishment.galleries.build.gallery_images.build

    # Asignar categoría automáticamente para restaurantes
    @restaurant.establishment.category = :restaurante

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @restaurant.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
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

    # Asignar categoría automáticamente para restaurantes si no viene del formulario
    @restaurant.establishment.category = :restaurante if @restaurant.establishment.category.blank?

    # Asignar usuario ANTES de cualquier validación
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @restaurant.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @restaurant.establishment.user = current_user
    end

    if @restaurant.save
      redirect_to @restaurant, notice: "Restaurante creado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@restaurant) || "No pudimos guardar el restaurante. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
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
      flash.now[:alert] = helpers.validation_summary_text(@restaurant) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @restaurant.establishment.destroy!
    redirect_to restaurants_path, notice: "Restaurante eliminado."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to restaurants_path, alert: "No se puede eliminar este restaurante porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to restaurants_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_restaurant
    @restaurant = Restaurant.includes(
      :restaurant_tables,
      { menus: [:menu_items] },
      establishment: [:legal_info, :user, :country, :city, :province, :units, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def authorize_create_restaurant!
    return if current_user.administrador?
    return if current_user.afiliado?

    redirect_to restaurants_path, alert: "No tienes permisos para crear restaurantes."
  end

  def authorize_modify_restaurant!
    return if current_user.administrador?
    return if current_user.afiliado? && @restaurant.establishment&.user_id == current_user.id

    redirect_to restaurants_path, alert: "No tienes permisos para modificar este restaurante."
  end

  def restaurant_params_1
    params.require(:restaurant).permit(:cuisine_type, :category)
  end

  def restaurant_params
    params.require(:restaurant).permit(
      :cuisine_type, :category,
      :total_tables, :seats_per_table, :available_tables, :total_capacity,
      menus_attributes: [
        :id, :name, :_destroy,
        menu_items_attributes: [
          :id, :name, :description, :price, :photo, :_destroy
        ]
      ],
      restaurant_tables_attributes: [
        :id, :name, :table_type, :seats, :quantity, :description, :_destroy
      ],
      establishment_attributes: [
        :user_id,
        :id,
        :name, # Nombre público
        :short_description,
        :description,
        :long_description,
        :address,
        :phone,
        :whatsapp,
        :email,
        :website,
        :status,
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
        :opening_time,
        :closing_time,
        :video,
        :video_url,
        policies: [],
        amenity_ids: [],
        images: [],
        legal_info_attributes: [
          :id,
          :business_name, # Razón social
          :document_type, # Tipo de documento
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
