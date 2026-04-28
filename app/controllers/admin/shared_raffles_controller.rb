class Admin::SharedRafflesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_shared_raffle, only: [:show, :edit, :update, :destroy,
                                            :draw_winner, :assign_event, :remove_event]
  layout "dashboard"

  def index
    @shared_raffles = SharedRaffle.order(created_at: :desc)
  end

  def show
    @winner          = @shared_raffle.winner
    @assigned_events = @shared_raffle.events.order(:event_date)
    @available_events = Event.where.not(id: @assigned_events.select(:id)).order(:name)
  end

  def new
    @shared_raffle    = SharedRaffle.new
    @available_events = Event.order(:name)
  end

  def create
    @shared_raffle = SharedRaffle.new(shared_raffle_params)
    if @shared_raffle.save
      Array(params[:event_ids]).reject(&:blank?).each do |id|
        @shared_raffle.assign_event!(Event.find(id))
      end
      redirect_to admin_shared_raffle_path(@shared_raffle),
                  notice: "Sorteo multi-evento creado correctamente."
    else
      @available_events = Event.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_events = Event.where.not(id: @shared_raffle.events.select(:id)).order(:name)
  end

  def update
    if @shared_raffle.update(shared_raffle_params)
      redirect_to admin_shared_raffle_path(@shared_raffle),
                  notice: "Sorteo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shared_raffle.destroy
    redirect_to admin_shared_raffles_path, notice: "Sorteo eliminado."
  end

  def draw_winner
    if @shared_raffle.draw_winner!
      redirect_to admin_shared_raffle_path(@shared_raffle),
                  notice: "¡Ganador seleccionado! Número: #{@shared_raffle.winning_number}"
    else
      redirect_to admin_shared_raffle_path(@shared_raffle),
                  alert: "No se pudo realizar el sorteo. Verifica que haya tickets activos en los eventos asignados."
    end
  end

  # POST — asignar un evento al sorteo (también llamado desde la vista del evento)
  def assign_event
    event = Event.find(params[:event_id])
    @shared_raffle.assign_event!(event)
    redirect_back fallback_location: admin_shared_raffle_path(@shared_raffle),
                  notice: "Evento '#{event.name}' asignado al sorteo. #{@shared_raffle.tickets_for_event(event).count} ticket(s) participan ahora."
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: admin_shared_raffle_path(@shared_raffle),
                  alert: "No se pudo asignar el evento: #{e.message}"
  end

  # DELETE — desasignar un evento del sorteo
  def remove_event
    event = Event.find(params[:event_id])
    @shared_raffle.remove_event!(event)
    redirect_back fallback_location: admin_shared_raffle_path(@shared_raffle),
                  notice: "Evento '#{event.name}' removido del sorteo."
  end

  private

  def set_shared_raffle
    @shared_raffle = SharedRaffle.find(params[:id])
  end

  def shared_raffle_params
    params.require(:shared_raffle).permit(:name, :prize, :draw_date, :description)
  end
end
