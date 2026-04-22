class Admin::VendedoresController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_event
  layout "dashboard"

  def index
    @event_vendedores = @event.event_vendedores.includes(:user).order(created_at: :desc)
  end

  def show
    @event_vendedor = @event.event_vendedores.includes(:user).find(params[:id])
    @vendedor       = @event_vendedor.user
    @tickets_sold   = @event_vendedor.tickets_sold
    @tickets_pending = @event_vendedor.tickets_pending
    @tickets_rejected = Ticket.where(vendedor: @vendedor, event: @event, status: :cancelado).count
    @tickets_all    = Ticket.where(vendedor: @vendedor, event: @event).order(created_at: :desc)
    @revenue        = Ticket.where(vendedor: @vendedor, event: @event, status: [:activo, :usado])
                            .sum(:total_price)
  end

  def new
    @event_vendedor = @event.event_vendedores.build
    @vendedores = User.where(role: :vendedor)
                      .where.not(id: @event.vendedores.select(:id))
  end

  def create
    @event_vendedor = @event.event_vendedores.build(event_vendedor_params)

    if @event_vendedor.save
      redirect_to admin_event_path(@event),
                  notice: "Vendedor asignado al evento exitosamente."
    else
      redirect_to admin_event_path(@event),
                  alert: @event_vendedor.errors.full_messages.join(", ")
    end
  end

  def update
    @event_vendedor = @event.event_vendedores.find(params[:id])
    if @event_vendedor.update(event_vendedor_params)
      redirect_to admin_event_vendedor_path(@event, @event_vendedor),
                  notice: "Cupo actualizado correctamente."
    else
      redirect_to admin_event_vendedor_path(@event, @event_vendedor),
                  alert: @event_vendedor.errors.full_messages.join(", ")
    end
  end

  def toggle_active
    ev = @event.event_vendedores.find(params[:id])
    ev.update!(active: !ev.active)
    redirect_to admin_event_path(@event),
                notice: "Estado del vendedor actualizado."
  end

  def destroy
    ev = @event.event_vendedores.find(params[:id])
    if Ticket.where(vendedor: ev.user, event: @event, status: :reservado).exists?
      redirect_to admin_event_path(@event),
                  alert: "No se puede remover un vendedor con tickets pendientes."
    else
      ev.destroy
      redirect_to admin_event_path(@event),
                  notice: "Vendedor removido del evento."
    end
  end

  def new_vendedor
    @user = User.new
  end

  def create_vendedor
    @user = User.new(vendedor_user_params)
    @user.role = :vendedor
    @user.skip_confirmation!

    if @user.save
      if params[:auto_assign] == "1"
        ev = @event.event_vendedores.create!(user: @user, active: true)
        ev.update(quota: params[:quota].presence&.to_i)
      end
      redirect_to admin_event_path(@event),
                  notice: "Vendedor #{@user.name} creado exitosamente."
    else
      redirect_to admin_event_path(@event),
                  alert: "Error al crear vendedor: #{@user.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def event_vendedor_params
    params.require(:event_vendedor).permit(:user_id, :active, :quota)
  end

  def vendedor_user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :country_id, :city_id)
  end
end
