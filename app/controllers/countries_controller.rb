class CountriesController < ApplicationController
  before_action :set_country, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    @countries = Country.all
  end

  def show
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to countries_path, notice: "País creado correctamente."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @country.update(country_params)
      redirect_to countries_path, notice: "País actualizado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @country.destroy
    redirect_to countries_path, notice: "País eliminado correctamente."
  end

  private

  def set_country
    @country = Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :code)
  end
end
