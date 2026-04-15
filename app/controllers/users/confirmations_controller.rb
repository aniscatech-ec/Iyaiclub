# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super
  end

  # POST /resource/confirmation
  def create
    super
  end

  protected

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    # Mensaje personalizado de confirmación
    flash[:notice] = "¡Tu cuenta ha sido verificada exitosamente! ¡Bienvenido a IyaiClub!"
    
    # Iniciar sesión automáticamente después de confirmar
    sign_in(resource)
    
    # Redirigir según el rol del usuario
    case resource.role
    when 'turista'
      turista_dashboard_index_path
    when 'afiliado'
      afiliado_dashboard_index_path
    when 'administrador'
      admin_dashboard_index_path
    else
      root_path
    end
  end

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    new_session_path(resource_name) if signed_in?(resource_name)
  end
end
