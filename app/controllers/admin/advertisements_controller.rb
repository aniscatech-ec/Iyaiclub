module Admin
  class AdvertisementsController < ApplicationController
    layout "dashboard"
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_advertisement, only: [:edit, :update, :destroy, :toggle_active]

    def index
      @advertisements = Advertisement.order(:position, :created_at)
    end

    def new
      @advertisement = Advertisement.new
    end

    def create
      @advertisement = Advertisement.new(advertisement_params)
      if @advertisement.save
        redirect_to admin_advertisements_path, notice: "Publicidad \"#{@advertisement.title}\" creada correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @advertisement.update(advertisement_params)
        redirect_to admin_advertisements_path, notice: "Publicidad actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @advertisement.destroy
      redirect_to admin_advertisements_path, notice: "Publicidad eliminada."
    end

    def toggle_active
      @advertisement.update!(active: !@advertisement.active)
      redirect_to admin_advertisements_path,
                  notice: "Publicidad #{@advertisement.active? ? 'activada' : 'desactivada'}."
    end

    private

    def set_advertisement
      @advertisement = Advertisement.find(params[:id])
    end

    def advertisement_params
      params.require(:advertisement).permit(:title, :description, :tags, :link_url, :active, :position, :image)
    end
  end
end
