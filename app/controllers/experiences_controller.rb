class ExperiencesController < ApplicationController
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_experience, only: [:show, :edit, :update, :destroy]

  def index
    if @establishment
      @experiences = @establishment.experiences
    else
      @experiences = Experience.all
    end
  end

  def show
  end

  def new
    if @establishment
      @experience = @establishment.experiences.build
    else
      @experience = Experience.new
    end
  end

  def create
    if @establishment
      @experience = @establishment.experiences.build(experience_params)
    else
      @experience = Experience.new(experience_params)
    end

    if @experience.save
      redirect_to @experience, notice: 'La experiencia ha sido creada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @experience.update(experience_params)
      redirect_to @experience, notice: 'La experiencia ha sido actualizada correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @establishment = @experience.establishment
    @experience.destroy
    redirect_to establishment_path(@establishment), notice: 'La experiencia fue eliminada exitosamente.'
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_experience
    @experience = Experience.find(params[:id])
  end

  def experience_params
    params.require(:experience).permit(:name, :description, :duration, :price, :requirements, :establishment_id)
  end
end
