class TourPackagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_travel_agency
  before_action :set_tour_package, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    @pagy, @tour_packages = pagy(@travel_agency.tour_packages.order(created_at: :desc))
  end

  def show
  end

  def new
    @tour_package = @travel_agency.tour_packages.build
  end

  def create
    @tour_package = @travel_agency.tour_packages.build(tour_package_params)
    if @tour_package.save
      redirect_to travel_agency_path(@travel_agency), notice: "Paquete turístico creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tour_package.update(tour_package_params)
      redirect_to travel_agency_path(@travel_agency), notice: "Paquete turístico actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tour_package.destroy
    redirect_to travel_agency_path(@travel_agency), notice: "Paquete turístico eliminado."
  end

  private

  def set_travel_agency
    @travel_agency = TravelAgency.find(params[:travel_agency_id])
  end

  def set_tour_package
    @tour_package = @travel_agency.tour_packages.find(params[:id])
  end

  def tour_package_params
    params.require(:tour_package).permit(:name, :duration, :itinerary, :price, :description, photos: [])
  end
end
