class Admin::RafflesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_event
  before_action :set_raffle, only: [:show, :draw_winner, :destroy]
  layout "dashboard"

  def index
    @raffles = @event.raffles.order(created_at: :desc)
  end

  def show
    @winner = @raffle.winner
  end

  def new
    @raffle = @event.raffles.build
  end

  def create
    @raffle = @event.raffles.build(raffle_params)
    
    if @raffle.save
      redirect_to admin_event_raffles_path(@event), notice: "Sorteo creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def draw_winner
    if @raffle.draw_winner!
      redirect_to admin_event_raffle_path(@event, @raffle), notice: "¡Ganador seleccionado exitosamente!"
    else
      redirect_to admin_event_raffles_path(@event), alert: "No se pudo realizar el sorteo. Verifica que haya tickets participantes."
    end
  end

  def destroy
    @raffle.destroy
    redirect_to admin_event_raffles_path(@event), notice: "Sorteo eliminado correctamente."
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_raffle
    @raffle = @event.raffles.find(params[:id])
  end

  def raffle_params
    params.require(:raffle).permit(:prize, :draw_date)
  end
end
