class ProvincesController < ApplicationController
  before_action :set_province, only: %i[show edit update destroy]
  layout "dashboard"

  # GET /provinces
  def index
    @provinces = Province.all
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

  def province_params
    params.require(:province).permit(:name) # asumiendo que la provincia tiene un atributo `name`
  end
end
