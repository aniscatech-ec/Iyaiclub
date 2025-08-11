class Admin::UsersController < ApplicationController
  layout "dashboard"
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "Usuario creado correctamente."
    else
      render :new
    end
  end

  def edit; end

  # def update
  #   if @user.update(user_params)
  #     redirect_to admin_users_path, notice: "Usuario actualizado."
  #   else
  #     render :edit
  #   end
  # end


  def update
    @user = User.find(params[:id])

    # Si el password viene vacío, lo quitamos de los parámetros
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Usuario actualizado correctamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "Usuario eliminado."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :role)
  end
end
