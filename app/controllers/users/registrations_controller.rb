# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
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
