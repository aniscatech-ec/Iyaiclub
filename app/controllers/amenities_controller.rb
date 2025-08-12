class AmenitiesController < ApplicationController
  before_action :set_amenity, only: %i[ show edit update destroy ]
  layout "dashboard"

  # GET /amenities or /amenities.json
  def index
    @amenities = Amenity.all
  end

  # GET /amenities/1 or /amenities/1.json
  def show
  end

  # GET /amenities/new
  def new
    @amenity = Amenity.new
  end

  # GET /amenities/1/edit
  def edit
  end

  # POST /amenities or /amenities.json
  def create
    @amenity = Amenity.new(amenity_params)

    respond_to do |format|
      if @amenity.save
        format.html { redirect_to @amenity, notice: "Amenity was successfully created." }
        format.json { render :show, status: :created, location: @amenity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @amenity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /amenities/1 or /amenities/1.json
  def update
    respond_to do |format|
      if @amenity.update(amenity_params)
        format.html { redirect_to @amenity, notice: "Amenity was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @amenity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @amenity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /amenities/1 or /amenities/1.json
  def destroy
    @amenity.destroy!

    respond_to do |format|
      format.html { redirect_to amenities_path, notice: "Amenity was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_amenity
      @amenity = Amenity.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def amenity_params
      params.expect(amenity: [ :name ])
    end
end
