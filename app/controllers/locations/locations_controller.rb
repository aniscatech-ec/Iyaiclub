class Locations::LocationsController < ApplicationController
  def provinces
    country = Country.find(params[:country_id])
    provinces = country.provinces.order(:name)
    render json: provinces.as_json(only: [:id, :name])
  rescue ActiveRecord::RecordNotFound
    render json: [], status: :not_found
  end

  def cities
    province = Province.find(params[:province_id])
    cities = province.cities.order(:name)
    render json: cities.as_json(only: [:id, :name])
  rescue ActiveRecord::RecordNotFound
    render json: [], status: :not_found
  end
end
