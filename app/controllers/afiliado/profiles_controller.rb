class Afiliado::ProfilesController < ApplicationController
  before_action :authenticate_afiliado!
  layout "dashboard"

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to afiliado_profile_path, notice: "Perfil actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :phone, :birth_date, :avatar, :cover_photo)
  end
end
