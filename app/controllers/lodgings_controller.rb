class LodgingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_lodging, only: [:show, :edit, :update, :destroy]
  before_action :authorize_create!, only: [:new, :create]
  before_action :authorize_modify!, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    if @establishment
      lodgings = @establishment.lodgings
    else
      lodgings = Lodging.includes(:establishment)
    end

    # Afiliados solo ven sus propios hospedajes
    if current_user.afiliado?
      lodgings = lodgings.joins(:establishment).where(establishments: { user_id: current_user.id })
    end

    @lodgings = lodgings
  end

  def show
  end

  def new
    if @establishment
      @lodging = @establishment.lodgings.build
    else
      @lodging = Lodging.new
    end
  end

  def create
    if @establishment
      @lodging = @establishment.lodgings.build(lodging_params)
    else
      @lodging = Lodging.new(lodging_params)
    end

    if @lodging.save
      redirect_to @lodging, notice: 'El hospedaje ha sido creado correctamente.'
    else
      flash.now[:alert] = helpers.validation_summary_text(@lodging) || "No pudimos guardar el hospedaje. Revisa los campos marcados en rojo."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @lodging.update(lodging_params)
      redirect_to @lodging, notice: 'El hospedaje ha sido actualizado correctamente.'
    else
      flash.now[:alert] = helpers.validation_summary_text(@lodging) || "No pudimos guardar los cambios. Revisa los campos marcados en rojo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @establishment = @lodging.establishment
    @lodging.destroy!
    redirect_to lodgings_path, notice: 'El hospedaje fue eliminado exitosamente.'
  rescue ActiveRecord::InvalidForeignKey
    redirect_to lodgings_path, alert: "No se puede eliminar este hospedaje porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to lodgings_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_lodging
    @lodging = Lodging.find(params[:id])
  end

  def authorize_create!
    return if current_user.administrador?
    return if current_user.afiliado?
    redirect_to lodgings_path, alert: "No tienes permisos para crear hospedajes."
  end

  def authorize_modify!
    return if current_user.administrador?
    return if current_user.afiliado? && @lodging.establishment&.user_id == current_user.id
    redirect_to lodgings_path, alert: "No tienes permisos para acceder a este hospedaje."
  end

  def lodging_params
    params.require(:lodging).permit(:lodging_type, :price_per_night, :check_in_time, :check_out_time, :rules, :establishment_id)
  end
end
