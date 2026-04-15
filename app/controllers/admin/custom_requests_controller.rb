class Admin::CustomRequestsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_custom_request, only: [:show, :update, :destroy, :assign, :change_status]
  layout "dashboard"

  def index
    @custom_requests = CustomRequest.includes(:user, :assigned_to).recent
    @custom_requests = @custom_requests.where(status: params[:status])                 if params[:status].present?
    @custom_requests = @custom_requests.where(experience_type: params[:experience_type]) if params[:experience_type].present?

    if params[:q].present?
      term = "%#{params[:q]}%"
      @custom_requests = @custom_requests.where("destination LIKE ? OR comments LIKE ?", term, term)
    end

    @pagy, @custom_requests = pagy(@custom_requests, items: 20) if respond_to?(:pagy)
  end

  def show
    @admins = User.where(role: :administrador)
  end

  def update
    if @custom_request.update(custom_request_params)
      redirect_to admin_custom_request_path(@custom_request), notice: "Solicitud actualizada correctamente."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_request.destroy
    redirect_to admin_custom_requests_path, notice: "Solicitud eliminada."
  end

  def assign
    if @custom_request.update(assigned_to_id: params[:assigned_to_id])
      redirect_to admin_custom_request_path(@custom_request), notice: "Solicitud asignada correctamente."
    else
      redirect_to admin_custom_request_path(@custom_request), alert: "No fue posible asignar la solicitud."
    end
  end

  def change_status
    new_status = params[:status]
    if CustomRequest.statuses.key?(new_status) && @custom_request.update(status: new_status)
      redirect_to admin_custom_request_path(@custom_request), notice: "Estado actualizado a #{new_status.humanize}."
    else
      redirect_to admin_custom_request_path(@custom_request), alert: "No fue posible cambiar el estado."
    end
  end

  private

  def set_custom_request
    @custom_request = CustomRequest.find(params[:id])
  end

  def custom_request_params
    params.require(:custom_request).permit(:status, :assigned_to_id, :comments)
  end
end
