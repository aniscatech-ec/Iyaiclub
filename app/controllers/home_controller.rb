class HomeController < ApplicationController
  def index
    @upcoming_events  = Event.published.upcoming.order(event_date: :asc).limit(5)
    @advertisements   = Advertisement.active_ads
  end

  def home

  end
end
