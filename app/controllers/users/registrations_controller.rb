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
  # Vista que se muestra después del registro informando al usuario
  # que debe revisar su correo para confirmar la cuenta
  def confirmation_pending
    @email = params[:email] || session[:pending_confirmation_email]
    redirect_to new_user_session_path unless @email.present?
  end

  protected

  # Después de registrarse, si se requiere confirmación, guardamos el email
  # en sesión y redirigimos a la vista de "revisa tu correo".
  # Limpiamos el flash de Devise para evitar mostrar el mensaje duplicado
  # (toda esa información ya está en la vista de confirmation_pending).
  def after_inactive_sign_up_path_for(resource)
    session[:pending_confirmation_email] = resource.email
    flash.delete(:notice)
    users_confirmation_pending_path(email: resource.email)
  end
end
