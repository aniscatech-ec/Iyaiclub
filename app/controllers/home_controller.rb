class HomeController < ApplicationController
  def index
    @upcoming_events  = Event.published.upcoming.order(event_date: :asc).limit(5)
    @advertisements   = Advertisement.active_ads

    # Escapadas destacadas (aprobadas, activas)
    @featured_getaways = Establishment.joins(:getaways)
                           .includes(:getaways, :city, :province)
                           .where(status: :active, approval_status: :approved)
                           .order("RAND()")
                           .limit(6)

    # Hoteles destacados
    @featured_hotels = Establishment.joins(:hotel)
                         .includes(:hotel, :city, :province)
                         .where(status: :active, approval_status: :approved)
                         .order("RAND()")
                         .limit(6)

    # Restaurantes destacados
    @featured_restaurants = Establishment.joins(:restaurant)
                              .includes(:restaurant, :city, :province)
                              .where(status: :active, approval_status: :approved)
                              .order("RAND()")
                              .limit(4)

    # Sitios cerca del usuario (misma ciudad si está logueado)
    if user_signed_in? && current_user.city_id.present?
      @nearby = Establishment.where(city_id: current_user.city_id, status: :active, approval_status: :approved)
                  .includes(:hotel, :getaways, :restaurant, :city, :province)
                  .order("RAND()").limit(6)
    end

    # Para el banner "¿Eres afiliado?" — solo se muestra a no logueados o turistas
    @show_affiliate_banner = !user_signed_in? || current_user.turista?
  end

  def home
  end
end
