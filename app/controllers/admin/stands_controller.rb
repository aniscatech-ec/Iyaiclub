class Admin::StandsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_stand, only: [:show, :edit, :update, :destroy]
  layout "dashboard"

  def index
    @stands = Stand.order(created_at: :desc)
  end

  def show
  end

  def new
    @stand = Stand.new
  end

  def create
    @stand = Stand.new(stand_params)
    if @stand.save
      redirect_to admin_stands_path, notice: "Stand creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stand.update(stand_params)
      redirect_to admin_stands_path, notice: "Stand actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stand.destroy!
    redirect_to admin_stands_path, notice: "Stand eliminado."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to admin_stands_path, alert: "No se puede eliminar este stand porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to admin_stands_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def set_stand
    @stand = Stand.find(params[:id])
  end

  def stand_params
    params.require(:stand).permit(:name, :owner_name, :owner_lastname, :location, :ruc, :email, :country_id, :city_id, :active)
  end
end
