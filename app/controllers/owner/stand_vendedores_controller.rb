class Owner::StandVendedoresController < Owner::BaseController
  before_action :set_event, only: [:new, :create]

  def index
    @vendors = EventVendedor.includes(:user, :event)
                            .where(stand: current_stand)
                            .order(created_at: :desc)
  end

  def new
    @vendedor = EventVendedor.new
    @available_vendors = User.where(role: :vendedor)
                             .where.not(id: @event.vendedores.select(:id))
                             .order(:name)
  end

  def create
    user = User.find_by(id: params[:user_id])

    if user.nil?
      return redirect_to owner_stand_vendedores_path, alert: "Usuario no encontrado."
    end

    vendedor = @event.event_vendedores.build(
      user:        user,
      stand:       current_stand,
      vendor_type: :stand,
      active:      true
    )

    if vendedor.save
      redirect_to owner_stand_path, notice: "Vendedor asignado correctamente."
    else
      redirect_to owner_stand_path, alert: vendedor.errors.full_messages.join(", ")
    end
  end

  def destroy
    assignment = EventVendedor.where(stand: current_stand).find(params[:id])
    assignment.destroy!
    redirect_to owner_stand_vendedores_path, notice: "Vendedor eliminado del stand."
  rescue ActiveRecord::RecordNotFound
    redirect_to owner_stand_vendedores_path, alert: "Asignación no encontrada."
  end

  private

  def set_event
    @event = current_stand.events.find_by(id: params[:event_id])
    redirect_to owner_stand_path, alert: "Evento no encontrado." unless @event
  end
end
