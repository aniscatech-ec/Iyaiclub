class CitiesController < ApplicationController
  before_action :set_city, only: %i[show edit update destroy]
  before_action :set_provinces, only: %i[new edit create update]
  layout "dashboard"
  # GET /cities
  def index
    @cities = City.includes(:province).all
  end
  def autocomplete
    cities = City.where("name LIKE ?", "%#{params[:q]}%").limit(10)
    render json: cities.pluck(:name)
  end

  # GET /cities/:id
  def show
  end

  # GET /cities/new
  def new
    @city = City.new
  end

  # POST /cities
  def create
    @city = City.new(city_params)
    if @city.save
      redirect_to @city, notice: "City was successfully created."
    else
      render :new
    end
  end

  # GET /cities/:id/edit
  def edit
  end

  # PATCH/PUT /cities/:id
  def update
    if @city.update(city_params)
      redirect_to @city, notice: "City was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /cities/:id
  def destroy
    @city.destroy
    redirect_to cities_url, notice: "City was successfully destroyed."
  end

  private

  def set_city
    @city = City.find(params[:id])
  end

  def set_provinces
    @provinces = Province.all
  end

  def city_params
    params.require(:city).permit(:name, :province_id)
  end
end
