class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :role, :country_id, :city_id, :birth_date, :terms_accepted, :marketing_consent])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :role, :country_id, :city_id, :birth_date, :terms_accepted, :marketing_consent])
  end

  # Control de acceso a diferentes controladores
  def authenticate_afiliado!
    authenticate_user!
    redirect_to root_path, alert: "Acceso denegado" unless current_user.afiliado?
  end

  def authenticate_turista!
    authenticate_user!
    redirect_to root_path, alert: "Acceso denegado" unless current_user.turista?
  end

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, alert: "Acceso denegado" unless current_user.administrador?
  end

  # al iniciar sesión cada usuario vaya a su dashboard
  def after_sign_in_path_for(resource)
    case resource.role
    when "administrador"
      admin_dashboard_index_path
    when "afiliado"
      afiliado_dashboard_index_path
    when "turista"
      turista_dashboard_index_path
    else
      root_path
    end
  end

  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller? && action_name == "edit" && controller_name == "registrations"
      "dashboard"
      # Si el usuario está logueado y entra a controladores del panel
      # elsif user_signed_in? && controller_path.start_with?("dashboard", "establishments", "amenities")
    elsif user_signed_in?
      "dashboard"
      # Por defecto, usa el layout público
    else
      "application"
    end
  end

end
