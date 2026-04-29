# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication, only: [:confirmation_pending]
  before_action :block_vendedor_edit, only: [:edit, :update]

  private

  def block_vendedor_edit
    if current_user&.vendedor?
      redirect_to vendedor_dashboard_index_path,
                  alert: "Los vendedores no pueden editar su perfil. Contacta a un administrador."
    end
  end

  public

  # GET /users/confirmation_pending
  def confirmation_pending
    @email = params[:email] || session[:pending_confirmation_email]
    redirect_to new_user_session_path unless @email.present?
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    session[:pending_confirmation_email] = resource.email
    flash.delete(:notice)
    users_confirmation_pending_path(email: resource.email)
  end

  # Permite subir los documentos de identidad en el registro
  def sign_up_params
    params.require(:user).permit(
      :name, :phone, :role, :email,
      :country_id, :city_id, :birth_date,
      :password, :password_confirmation,
      :terms_accepted, :marketing_consent,
      :cedula_front, :cedula_back, :ruc_document
    )
  end

  def account_update_params
    params.require(:user).permit(
      :name, :phone, :email,
      :password, :password_confirmation, :current_password,
      :birth_date, :avatar, :cover_photo
    )
  end
end
