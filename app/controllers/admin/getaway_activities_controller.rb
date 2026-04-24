class Admin::GetawayActivitiesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_admin!
  before_action :set_activity, only: [:edit, :update, :destroy]

  def index
    @activities = GetawayActivity.ordered
  end

  def new
    @activity = GetawayActivity.new
  end

  def create
    @activity = GetawayActivity.new(activity_params)
    if @activity.save
      redirect_to admin_getaway_activities_path, notice: "Actividad creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @activity.update(activity_params)
      redirect_to admin_getaway_activities_path, notice: "Actividad actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to admin_getaway_activities_path, notice: "Actividad eliminada."
  end

  private

  def set_activity
    @activity = GetawayActivity.find(params[:id])
  end

  def activity_params
    params.require(:getaway_activity).permit(:name, :icon, :position)
  end
end
