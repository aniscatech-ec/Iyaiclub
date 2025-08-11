class Afiliado::DashboardController < ApplicationController
  before_action :authenticate_afiliado!
  layout "dashboard"

  def index
  end
end
