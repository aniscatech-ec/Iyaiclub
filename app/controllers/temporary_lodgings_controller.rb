class TemporaryLodgingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_temporary_lodging, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create!, only: [:new, :create]
  before_action :authorize_modify!, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    lodgings = TemporaryLodging.includes(
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    )
    if params[:type].present? && TemporaryLodging::LODGING_TYPES.include?(params[:type])
      lodgings = lodgings.where(lodging_type: params[:type])
    end

    # Afiliados solo ven sus propios alojamientos
    if current_user.afiliado?
      lodgings = lodgings.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @pagy, @temporary_lodgings = pagy(lodgings)
    @current_type = params[:type]
  end

  def show
  end

  def new
    @temporary_lodging = TemporaryLodging.new
    @temporary_lodging.build_establishment
    @temporary_lodging.establishment.build_legal_info
    @temporary_lodging.establishment.galleries.build.gallery_images.build

    # Asignar categoría automáticamente para alojamientos temporales
    @temporary_lodging.establishment.category = :alojamiento_temporal

    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @temporary_lodging.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @temporary_lodging.establishment.user = current_user
    end
  end

  def edit
    @temporary_lodging.build_establishment unless @temporary_lodging.establishment
    @temporary_lodging.establishment.build_legal_info unless @temporary_lodging.establishment.legal_info
  end

  def create
    @temporary_lodging = TemporaryLodging.new(temporary_lodging_params)

    # Asignar categoría automáticamente para alojamientos temporales si no viene del formulario
    @temporary_lodging.establishment.category = :alojamiento_temporal if @temporary_lodging.establishment.category.blank?

    # Asignar usuario ANTES de cualquier validación
    if params[:user_id].present?
      @affiliate = User.find(params[:user_id])
      @temporary_lodging.establishment.user = @affiliate
    elsif current_user&.afiliado? || current_user&.administrador?
      @temporary_lodging.establishment.user = current_user
    end

    if @temporary_lodging.save
      redirect_to @temporary_lodging, notice: "Alojamiento temporal creado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@temporary_lodging) || "No pudimos guardar el alojamiento. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @temporary_lodging.update(temporary_lodging_params)
      if params[:gallery_uploads].present?
        params[:gallery_uploads].each do |gallery_id, files|
          next if files.blank?
          gallery = Gallery.find_by(id: gallery_id.to_i)
          next unless gallery
          files.each do |uploaded_file|
            gallery.gallery_images.create(file: uploaded_file)
          end
        end
      end

      redirect_to @temporary_lodging, notice: "Alojamiento temporal actualizado correctamente."
    else
      flash.now[:alert] = helpers.validation_summary_text(@temporary_lodging) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @temporary_lodging.establishment.destroy!
    redirect_to temporary_lodgings_path, notice: "Alojamiento temporal eliminado correctamente."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to temporary_lodgings_path, alert: "No se puede eliminar este alojamiento porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to temporary_lodgings_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_temporary_lodging
    @temporary_lodging = TemporaryLodging.includes(
      { rooms: [:room_beds, :amenities, { photo_attachment: :blob }] },
      establishment: [:legal_info, :user, :country, :city, :province, :amenities,
                       { galleries: { gallery_images: { file_attachment: :blob } } }]
    ).find(params[:id])
  end

  def authorize_create!
    return if current_user.administrador?
    return if current_user.afiliado?
    redirect_to temporary_lodgings_path, alert: "No tienes permisos para crear alojamientos temporales."
  end

  def authorize_modify!
    return if current_user.administrador?
    return if current_user.afiliado? && @temporary_lodging.establishment&.user_id == current_user.id
    redirect_to temporary_lodgings_path, alert: "No tienes permisos para acceder a este alojamiento."
  end

  def temporary_lodging_params
    params.require(:temporary_lodging).permit(
      :lodging_type,
      :max_guests,
      :total_rooms,
      :total_bathrooms,
      rooms_attributes: [
        :id, :name, :room_type,
        :price_per_night, :guest_capacity, :description,
        :quantity, :photo, :_destroy,
        amenity_ids: [],
        room_beds_attributes: [:id, :bed_type, :quantity, :_destroy]
      ],
      establishment_attributes: [
        :id,
        :user_id,
        :name,
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
        :check_in_time,
        :check_out_time,
        :video,
        :video_url,
        :status,
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
