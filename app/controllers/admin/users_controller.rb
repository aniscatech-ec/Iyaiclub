class Admin::UsersController < ApplicationController
  layout "dashboard"
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # def index
  #   @users = User.all
  # end
  def index
    if params[:role].present? && User.roles.key?(params[:role])
      @users = User.where(role: User.roles[params[:role]])
    else
      @users = User.all
    end
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

  def establishments
    user = User.find(params[:id])
    establishments = user.establishments

    respond_to do |format|
      format.json { render json: establishments.select(:id, :name) }
    end
  end

  # GET /admin/users/by_role?role=afiliado
  def users_by_role
    role = params[:role]
    users = User.where(role: role)
    render json: users.select(:id, :name)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :role, :country_id, :city_id, :birth_date, :terms_accepted, :marketing_consent)
  end
end
