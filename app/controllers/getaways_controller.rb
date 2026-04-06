class GetawaysController < ApplicationController
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_getaway, only: [:show, :edit, :update, :destroy]

  def index
    if @establishment
      @getaways = @establishment.getaways
    else
      @getaways = Getaway.includes(:establishment)
      @getaways = @getaways.where(subcategory: params[:sub]) if params[:sub].present?
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
    @establishment = @getaway.establishment
    @establishment.build_legal_info unless @establishment.legal_info
  end

  def update
    @establishment = @getaway.establishment
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
    params.require(:getaway).permit(
      :subcategory, :entry_price, :recommendations, :rules, :establishment_id,
      establishment_attributes: [
        :id, :name, :description, :short_description, :address, :phone, :whatsapp, :email, :website,
        :country_id, :province_id, :city_id, :latitude, :longitude, :arrival_instructions,
        :opening_time, :closing_time, :status, :policies, :user_id,
        { images: [], amenity_ids: [] },
        legal_info_attributes: [
          :id, :business_name, :legal_representative, :document_type, :document_number,
          :contact_email, :contact_phone
        ]
      ]
    )
  end
end
