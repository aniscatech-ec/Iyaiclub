class Admin::PlanVendedoresController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_plan
  layout "dashboard"

  def create
    vendedor = User.find_by(id: params[:vendedor_id], role: :vendedor)
    unless vendedor
      redirect_to edit_admin_plan_path(@plan), alert: "Usuario no válido o no es vendedor."
      return
    end

    pv = @plan.plan_vendedores.build(vendedor: vendedor)
    if pv.save
      redirect_to edit_admin_plan_path(@plan), notice: "#{vendedor.name} asignado correctamente."
    else
      redirect_to edit_admin_plan_path(@plan), alert: pv.errors.full_messages.join(', ')
    end
  end

  def destroy
    pv = PlanVendedor.find(params[:id])
    name = pv.vendedor.name
    pv.destroy
    redirect_to edit_admin_plan_path(@plan), notice: "#{name} eliminado del plan."
  end

  def toggle_active
    pv = PlanVendedor.find(params[:id])
    pv.update!(active: !pv.active)
    redirect_to edit_admin_plan_path(@plan),
                notice: "#{pv.vendedor.name} #{pv.active? ? 'activado' : 'desactivado'}."
  end

  private

  def set_plan
    @plan = Plan.find(params[:plan_id])
  end
end
