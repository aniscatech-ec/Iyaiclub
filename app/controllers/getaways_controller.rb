class GetawaysController < ApplicationController
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_getaway, only: [:show, :edit, :update, :destroy]

  def index
    if @establishment
      @getaways = @establishment.getaways
    else
      @getaways = Getaway.all
    end
  end

  def show
  end

  def new
    if @establishment
      @getaway = @establishment.getaways.build
    else
      @getaway = Getaway.new
    end
  end

  def create
    if @establishment
      @getaway = @establishment.getaways.build(getaway_params)
    else
      @getaway = Getaway.new(getaway_params)
    end

    if @getaway.save
      redirect_to @getaway, notice: 'La escapada ha sido creada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @getaway.update(getaway_params)
      redirect_to @getaway, notice: 'La escapada ha sido actualizada correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @establishment = @getaway.establishment
    @getaway.destroy
    redirect_to establishment_path(@establishment), notice: 'La escapada fue eliminada.'
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_getaway
    @getaway = Getaway.find(params[:id])
  end

  def getaway_params
    params.require(:getaway).permit(:subcategory, :entry_price, :recommendations, :rules, :establishment_id)
  end
end
