class ExperiencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent, only: [:index, :new, :create]
  before_action :set_experience, only: [:show, :edit, :update, :destroy]
  before_action :authorize_manage!, only: [:new, :create, :edit, :update, :destroy]
  layout "dashboard"

  def index
    if @getaway
      @experiences = @getaway.experiences
    elsif @establishment
      @experiences = @establishment.experiences
    else
      @experiences = Experience.includes(:establishment, :getaway).all
    end
  end

  def show
  end

  def new
    if @getaway
      @experience = @getaway.experiences.build(establishment: @getaway.establishment)
    elsif @establishment
      @experience = @establishment.experiences.build
    else
      @experience = Experience.new
    end
  end

  def create
    if @getaway
      @experience = @getaway.experiences.build(experience_params)
      @experience.establishment = @getaway.establishment
    elsif @establishment
      @experience = @establishment.experiences.build(experience_params)
    else
      @experience = Experience.new(experience_params)
    end

    if @experience.save
      redirect_to redirect_after_save, notice: "La atracción «#{@experience.name}» ha sido creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @getaway      = @experience.getaway
    @establishment = @experience.establishment
  end

  def update
    if @experience.update(experience_params)
      redirect_to redirect_after_save, notice: "La atracción «#{@experience.name}» ha sido actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    parent = @experience.getaway || @experience.establishment
    @experience.destroy
    if parent.is_a?(Getaway)
      redirect_to getaway_path(parent), notice: "La atracción fue eliminada."
    else
      redirect_to establishment_path(parent), notice: "La experiencia fue eliminada exitosamente."
    end
  end

  private

  def set_parent
    if params[:getaway_id].present?
      @getaway = Getaway.find(params[:getaway_id])
      @establishment = @getaway.establishment
    elsif params[:establishment_id].present?
      @establishment = Establishment.find(params[:establishment_id])
    end
  end

  def set_experience
    @experience = Experience.includes(:establishment, :getaway).find(params[:id])
  end

  def authorize_manage!
    return if current_user.administrador?

    owner_establishment = @getaway&.establishment || @establishment || @experience&.establishment
    return if current_user.afiliado? && owner_establishment&.user_id == current_user.id

    redirect_to root_path, alert: "No tienes permisos para gestionar atracciones."
  end

  def redirect_after_save
    if @getaway || @experience&.getaway
      getaway_path(@getaway || @experience.getaway)
    elsif @establishment || @experience&.establishment
      establishment_path(@establishment || @experience.establishment)
    else
      experiences_path
    end
  end

  def experience_params
    params.require(:experience).permit(:name, :description, :duration, :price, :requirements, :establishment_id, :getaway_id)
  end
end
