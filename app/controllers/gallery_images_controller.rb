class GalleryImagesController < ApplicationController
  before_action :set_gallery

  # PATCH /.../gallery_images/:id/set_cover
  def set_cover
    @establishment = Establishment.find(params[:establishment_id])

    @gallery = @establishment.galleries.find(params[:gallery_id])

    @image = @gallery.gallery_images.find(params[:id])
    # Desmarcar todas las imágenes de todas las galerías del establecimiento
    GalleryImage.joins(:gallery)
                .where(galleries: { establishment_id: @establishment.id })
                .update_all(is_cover: false)

    # Marcar la actual como portada
    @image.update(is_cover: true)

    respond_to do |format|
      format.json { render json: { success: true, id: @image.id } }
      format.html { redirect_to establishment_galleries_path(@establishment), notice: "Portada actualizada" }
    end
  end

  def create
    @gallery = Gallery.find(params[:gallery_id])
    @comment = @gallery.gallery_images.create(gallery_image_params)
    redirect_to establishment_gallery_path(@gallery.establishment, @gallery)
  end


  def destroy
    @gallery = Gallery.find(params[:gallery_id])
    @gallery_image = @gallery.gallery_images.find(params[:id])
    @gallery_image.destroy
    # redirect_to establishment_gallery_path(@gallery.establishment, @gallery), status: :see_other
    redirect_to edit_establishment_gallery_path(@gallery.establishment, @gallery), status: :see_other

  end




  private

  def set_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

  def gallery_image_params
    params.require(:gallery_image).permit(:is_cover, :video_url, :file)
  end
end
