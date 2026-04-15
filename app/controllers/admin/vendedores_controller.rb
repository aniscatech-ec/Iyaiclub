class Admin::VendedoresController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_event
  layout "dashboard"

  def index
    @event_vendedores = @event.event_vendedores.includes(:user).order(created_at: :desc)
  end

  def new
    @event_vendedor = @event.event_vendedores.build
    @vendedores = User.where(role: :vendedor)
                      .where.not(id: @event.vendedores.select(:id))
  end

  def create
    @event_vendedor = @event.event_vendedores.build(event_vendedor_params)

    if @event_vendedor.save
      redirect_to edit_admin_event_path(@event),
                  notice: "Vendedor asignado al evento exitosamente."
    else
      redirect_to edit_admin_event_path(@event),
                  alert: @event_vendedor.errors.full_messages.join(", ")
    end
  end

  def toggle_active
    ev = @event.event_vendedores.find(params[:id])
    ev.update!(active: !ev.active)
    redirect_to edit_admin_event_path(@event),
                notice: "Estado del vendedor actualizado."
  end

  def destroy
    ev = @event.event_vendedores.find(params[:id])
    if Ticket.where(vendedor: ev.user, event: @event, status: :reservado).exists?
      redirect_to edit_admin_event_path(@event),
                  alert: "No se puede remover un vendedor con tickets pendientes."
    else
      ev.destroy
      redirect_to edit_admin_event_path(@event),
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
      @event.event_vendedores.create!(user: @user, active: true) if params[:auto_assign] == "1"
      redirect_to edit_admin_event_path(@event),
                  notice: "Vendedor #{@user.name} creado exitosamente."
    else
      redirect_to edit_admin_event_path(@event),
                  alert: "Error al crear vendedor: #{@user.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def event_vendedor_params
    params.require(:event_vendedor).permit(:user_id, :active)
  end

  def vendedor_user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :country_id, :city_id)
  end
end
