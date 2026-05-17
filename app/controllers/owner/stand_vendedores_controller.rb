class Owner::StandVendedoresController < Owner::BaseController
  def index
    vendors = EventVendedor.includes(:user, :event)
                           .where(stand: current_stand, vendor_type: :stand)
                           .order(created_at: :desc)
    @vendors_by_event = vendors.group_by(&:event)
  end

  def new
    @stand_events    = current_stand.events.order(:created_at)
    @available_vendors = User.where(role: :vendedor).order(:name)
  end

  def create
    event = current_stand.events.find_by(id: params[:event_id])
    unless event
      return redirect_to owner_stand_vendedores_path, alert: "Evento no encontrado o no pertenece a tu stand."
    end

    user = User.find_by(id: params[:user_id])
    unless user
      return redirect_to new_owner_stand_vendedor_path, alert: "Usuario no encontrado."
    end

    unless user.vendedor?
      return redirect_to new_owner_stand_vendedor_path, alert: "El usuario seleccionado no tiene rol de vendedor."
    end

    vendedor = event.event_vendedores.build(
      user:        user,
      stand:       current_stand,
      vendor_type: :stand,
      active:      true,
      quota:       params[:quota].presence
    )

    if vendedor.save
      redirect_to owner_stand_vendedores_path, notice: "#{user.name} fue asignado como vendedor correctamente."
    else
      redirect_to new_owner_stand_vendedor_path, alert: vendedor.errors.full_messages.join(", ")
    end
  end

  def destroy
    assignment = EventVendedor.where(stand: current_stand, vendor_type: :stand).find(params[:id])
    vendor_name = assignment.user.name
    assignment.destroy!
    redirect_to owner_stand_vendedores_path, notice: "#{vendor_name} fue removido del stand."
  rescue ActiveRecord::RecordNotFound
    redirect_to owner_stand_vendedores_path, alert: "Asignación no encontrada."
  end
end
