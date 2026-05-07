class Owner::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_stand_owner!
  layout "dashboard"

  private

  def authenticate_stand_owner!
    unless current_user.afiliado? && current_user.owned_stand.present?
      redirect_to root_path, alert: "No tienes acceso a esta sección."
    end
  end

  def current_stand
    @current_stand ||= current_user.owned_stand
  end
  helper_method :current_stand
end
