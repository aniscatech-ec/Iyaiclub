class Admin::StandsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_stand, only: [:show, :edit, :update, :destroy, :assign_vendor, :remove_vendor]
  layout "dashboard"

  def index
    @stands = Stand.includes(:owner_user).order(created_at: :desc)
  end

  def show
    @vendors = EventVendedor.includes(:user, :event)
                            .where(stand: @stand)
                            .order(created_at: :desc)
  end

  def new
    @stand = Stand.new
  end

  def create
    @stand = Stand.new(stand_params)
    assign_virtual_attributes(@stand)

    if @stand.save
      redirect_to admin_stands_path, notice: "Stand creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events        = @stand.events.order(:name)
    @all_vendors   = User.where(role: :vendedor).order(:name)
  end

  def update
    if @stand.update(stand_params)
      redirect_to edit_admin_stand_path(@stand), notice: "Stand actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stand.destroy!
    redirect_to admin_stands_path, notice: "Stand eliminado."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to admin_stands_path, alert: "No se puede eliminar este stand porque tiene registros asociados."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to admin_stands_path, alert: "No se pudo eliminar: #{e.record.errors.full_messages.join(', ')}"
  end

  # POST /admin/stands/:id/assign_vendor
  def assign_vendor
    event  = Event.find(params[:event_id])
    user   = User.find(params[:user_id])

    if event.event_vendedores.exists?(user: user)
      return redirect_to edit_admin_stand_path(@stand),
             alert: "#{user.name} ya está asignado a ese evento."
    end

    ev = event.event_vendedores.build(user: user, stand: @stand, vendor_type: :stand, active: true)

    if ev.save
      redirect_to edit_admin_stand_path(@stand), notice: "#{user.name} asignado correctamente."
    else
      redirect_to edit_admin_stand_path(@stand), alert: ev.errors.full_messages.join(", ")
    end
  end

  # DELETE /admin/stands/:id/remove_vendor
  def remove_vendor
    ev = EventVendedor.find(params[:event_vendedor_id])
    ev.destroy!
    redirect_to edit_admin_stand_path(@stand), notice: "Vendedor removido del stand."
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_admin_stand_path(@stand), alert: "Asignación no encontrada."
  end

  # GET /admin/stands/search_users?q=term&role=afiliado
  def search_users
    role   = params[:role].presence_in(%w[afiliado vendedor]) || "afiliado"
    query  = params[:q].to_s.strip
    users  = User.where(role: role)
                 .where("name LIKE :q OR email LIKE :q", q: "%#{query}%")
                 .order(:name)
                 .limit(20)

    render json: users.map { |u| { id: u.id, text: "#{u.name} (#{u.email})" } }
  end

  private

  def set_stand
    @stand = Stand.find(params[:id])
  end

  def stand_params
    params.require(:stand).permit(:name, :location, :active)
  end

  def assign_virtual_attributes(stand)
    p = params[:stand]
    stand.user_assignment_type = p[:user_assignment_type]
    stand.user_source           = p[:user_source]
    stand.existing_user_id      = p[:existing_user_id]
    stand.new_user_name         = p[:new_user_name]
    stand.new_user_lastname     = p[:new_user_lastname]
    stand.new_user_email        = p[:new_user_email]
    stand.new_user_ruc          = p[:new_user_ruc]
    stand.new_user_country_id   = p[:new_user_country_id]
    stand.new_user_city_id      = p[:new_user_city_id]
  end
end
