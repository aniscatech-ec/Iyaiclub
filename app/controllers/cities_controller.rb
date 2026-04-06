class CitiesController < ApplicationController
  before_action :set_city, only: %i[show edit update destroy]
  before_action :set_provinces, only: %i[new edit create update]
  before_action :set_countries, only: %i[new edit create update]
  layout "dashboard"
  # GET /cities
  # def index
  # @cities = City.includes(:province).all
  def index
    if params[:country_id]
      country = Country.find(params[:country_id])
      @cities = country.cities

      respond_to do |format|
        format.html
        format.json { render json: @cities.map { |c| { id: c.id, name: c.name } } }
      end
    elsif params[:province_id]
      province = Province.find(params[:province_id])
      @cities = province.cities

      respond_to do |format|
        format.html
        format.json { render json: @cities.map { |c| { id: c.id, name: c.name } } }
      end
    else
      @cities = City.includes(province: :country).all
    end
  end

  def autocomplete
    cities = City.where("name LIKE ?", "%#{params[:q]}%").limit(10)
    render json: cities.pluck(:name)
  end

  def cities
    province = Province.find(params[:province_id])
    cities = province.cities

    render json: cities.map { |c| { id: c.id, name: c.name } }
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

  def set_countries
    @countries = Country.all
  end

  def city_params
    params.require(:city).permit(:name, :province_id)
  end
end
