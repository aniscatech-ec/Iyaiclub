class EventsController < ApplicationController
  before_action :authenticate_user!, only: []
  before_action :set_event, only: [:show]

  def index
    @events = Event.where(status: :publicado)
                    .where("event_date >= ? OR event_date IS NULL", Date.current)
                    .order(event_date: :asc)
  end

  def show
    @ticket_count = current_user.tickets.where(event: @event).count if user_signed_in?
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end
end
