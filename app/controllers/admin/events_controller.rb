class Admin::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_event, only: [:show, :edit, :update, :destroy, :scanner]
  layout "dashboard"

  def index
    @events = Event.order(event_date: :desc)
    @events = @events.where(status: params[:status]) if params[:status].present?
  end

  def show
    @tickets = @event.tickets.order(created_at: :desc)
    @raffles = @event.raffles.order(created_at: :desc)
    @event_vendedores = @event.event_vendedores.includes(:user).order(created_at: :desc)
    @shared_raffles_assigned = @event.shared_raffles.order(created_at: :desc)
    @shared_raffles_available = SharedRaffle.pendiente.where.not(id: @shared_raffles_assigned.select(:id))
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      sync_stands(@event)
      if params[:notify_users] == "1"
        BroadcastEventJob.perform_later(@event.id)
        notice = "Evento creado. Se están enviando notificaciones por correo a todos los usuarios."
      else
        notice = "Evento creado correctamente."
      end
      redirect_to admin_event_path(@event), notice: notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      sync_stands(@event)
      redirect_to admin_event_path(@event), notice: "Evento actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ticket_count = @event.tickets.count
    @event.tickets.destroy_all
    @event.destroy
    redirect_to admin_events_path,
      notice: "Evento \"#{@event.name}\" eliminado correctamente#{ticket_count > 0 ? " junto a #{ticket_count} ticket(s)." : "."}",
      status: :see_other
  end

  def scanner
  end

  def verify_ticket
    ticket = Ticket.find_by(ticket_code: params[:ticket_code])

    unless ticket
      render json: { error: "Ticket no encontrado" }, status: :not_found
      return
    end

    render json: {
      id: ticket.id,
      ticket_code: ticket.ticket_code,
      raffle_number: ticket.raffle_number,
      guest_name: ticket.guest_name,
      event_name: ticket.event_name,
      status: ticket.status,
      used_at: ticket.used_at&.strftime("%d/%m/%Y %H:%M")
    }
  end

  def mark_ticket_used
    ticket = Ticket.find(params[:id])

    if ticket.activo?
      ticket.mark_as_used!
      render json: { success: true, message: "Ticket marcado como usado." }
    else
      render json: { success: false, error: "El ticket ya fue usado o está cancelado." }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :name, :description, :event_date, :location, :maps_url,
      :member_price, :non_member_price, :stand_price,
      :combo_quantity, :combo_discount,
      :total_tickets, :available_tickets, :status, :image, :notify_users
    )
  end

  # Sincroniza stands seleccionados. Solo actúa si el form los envió
  # (campo oculto stand_ids_submitted presente).
  def sync_stands(event)
    return unless params[:stand_ids_submitted].present?
    ids = Array(params[:stand_ids]).map(&:to_i).select(&:positive?)
    event.stand_ids = ids
  end
end
