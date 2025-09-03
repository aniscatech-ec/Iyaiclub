class ProvincesController < ApplicationController
  before_action :set_province, only: %i[show edit update destroy]
  before_action :set_countries, only: %i[new edit create update]
  layout "dashboard"

  # GET /provinces
  def index
    # @provinces = Province.all
    if params[:country_id] # viene desde AJAX
      country = Country.find(params[:country_id])
      @provinces= country.provinces

      respond_to do |format|
        format.html # usará app/views/cities/index.html.erb si la necesitas
        format.json { render json: @provinces.map { |c| { id: c.id, name: c.name } } }
      end
    else
      @provinces = Province.includes(:country).all # tu index global
    end
  end

  # GET /provinces/:id
  def show
  end

  # GET /provinces/new
  def new
    @province = Province.new
  end

  # POST /provinces
  def create
    @province = Province.new(province_params)
    if @province.save
      redirect_to @province, notice: "Province was successfully created."
    else
      render :new
    end
  end

  # GET /provinces/:id/edit
  def edit
  end

  # PATCH/PUT /provinces/:id
  def update
    if @province.update(province_params)
      redirect_to @province, notice: "Province was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /provinces/:id
  def destroy
    @province.destroy
    redirect_to provinces_url, notice: "Province was successfully destroyed."
  end

  private

  def set_province
    @province = Province.find(params[:id])
  end

  def set_countries
    @countries = Country.all
  end

  def province_params
    params.require(:province).permit(:name, :country_id) # asumiendo que la provincia tiene un atributo `name`
  end
end
