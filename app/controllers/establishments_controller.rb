class EstablishmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_establishment, only: %i[show edit update destroy]
  before_action :authorize_admin_or_owner!, only: %i[edit update destroy]
  layout "dashboard"

  def index
    @establishments = Establishment.all
    
    # if current_user.administrador?
    #   # if params[:establishment].present? && Establishment.categories.key?(params[:establishment])
    #   #   @establishments = Establishment.where(category: Establishment.categories[params[:establishment]])
    #   # else
    #     @establishments = Establishment.all
    #   # end
    # else
    #   @establishments = current_user.establishments
    # end
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

  end

end
