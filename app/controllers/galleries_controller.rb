class GalleriesController < ApplicationController
  # before_action :set_establishment

  def index
    @establishment = Establishment.find(params[:establishment_id])

  end

  def new
    @establishment = Establishment.find(params[:establishment_id])
    # @gallery = @establishment.galleries.new
  end

  def show
    @gallery = Gallery.find(params[:id])
  end

  def create
    @establishment = Establishment.find(params[:establishment_id])
    @gallery = @establishment.galleries.create(gallery_params)
    # if @gallery.save
    redirect_to establishment_gallery_path(@establishment, @gallery), notice: "Galería creada correctamente."
    # else
    #   render :new, status: :unprocessable_entity
    # end
  end

  def edit
    @gallery = Gallery.find(params[:id])
    # @gallery.gallery_images.build
  end

  def update
    @gallery = Gallery.find(params[:id])
    if @gallery.update(gallery_params)
      redirect_to establishment_gallery_path(@gallery.establishment, @gallery),
                  notice: "Galería actualizada con éxito."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gallery = Gallery.find(params[:id])
    @establishment = @gallery.establishment
    @gallery.destroy
    # redirect_to @establishment, notice: "Galería eliminada."
    puts "*************************************************************"
    puts @establishment.id
    puts @establishment.category
    puts "*************************************************************"

    case @establishment.category
    when "hotel"
      redirect_to hotel_path(@establishment.hotel), notice: "Galería eliminada correctamente."
    when "restaurante"
      redirect_to restaurant_path(@establishment), notice: "Galería eliminada correctamente."
    else
      redirect_to @establishment, notice: "Galería eliminada."
    end
  end



  private

  #
  # def set_establishment
  #   @establishment = Establishment.find(params[:establishment_id])
  # end

  def gallery_params
    params.require(:gallery).permit(:name, gallery_images_attributes: [:id, :file, :_destroy])
  end
end
