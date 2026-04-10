class LodgingsController < ApplicationController
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_lodging, only: [:show, :edit, :update, :destroy]

  def index
    if @establishment
      @lodgings = @establishment.lodgings
    else
      @lodgings = Lodging.all
    end
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
    @lodging.destroy
    redirect_to establishment_path(@establishment), notice: 'El hospedaje fue eliminado exitosamente.'
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_lodging
    @lodging = Lodging.find(params[:id])
  end

  def lodging_params
    params.require(:lodging).permit(:lodging_type, :price_per_night, :check_in_time, :check_out_time, :rules, :establishment_id)
  end
end
