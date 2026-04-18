class Users::SessionsController < Devise::SessionsController
  protected

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  # Mensajes de error más específicos al fallar el login
  def translation_scope
    "devise.sessions"
  end

  def flash_and_redirect(resource, scope, message, *args)
    super
  end

  # Override para personalizar el mensaje de falla según el caso
  def after_sign_in_failure
    email = params.dig(resource_name, :email).to_s.strip
    user  = User.find_by(email: email)

    if user.nil?
      flash.now[:alert] = "No encontramos una cuenta con ese correo electrónico."
    elsif !user.confirmed?
      flash.now[:alert] = "Tu cuenta aún no ha sido confirmada. Revisa tu correo o #{view_context.link_to('reenvía la confirmación', new_user_confirmation_path, class: 'alert-link')}.".html_safe
    else
      flash.now[:alert] = "La contraseña ingresada es incorrecta. ¿Olvidaste tu contraseña?"
    end

    render :new, status: :unprocessable_entity
  end
end
