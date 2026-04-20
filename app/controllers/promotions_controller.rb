class PromotionsController < ApplicationController
  before_action :set_establishment, only: [:index, :new, :create]
  before_action :set_promotion, only: [:show, :edit, :update, :destroy]

  def index
    if @establishment
      @promotions = @establishment.promotions
    else
      @promotions = Promotion.all
    end
  end

  def show
  end

  def new
    if @establishment
      @promotion = @establishment.promotions.build
    else
      @promotion = Promotion.new
    end
  end

  def create
    if @establishment
      @promotion = @establishment.promotions.build(promotion_params)
    else
      @promotion = Promotion.new(promotion_params)
    end

    if @promotion.save
      redirect_to @promotion, notice: 'La promoción ha sido creada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @promotion.update(promotion_params)
      redirect_to @promotion, notice: 'La promoción ha sido actualizada correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @establishment = @promotion.establishment
    @promotion.destroy
    redirect_to establishment_path(@establishment), notice: 'La promoción fue eliminada exitosamente.'
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id]) if params[:establishment_id].present?
  end

  def set_promotion
    @promotion = Promotion.find(params[:id])
  end

  def promotion_params
    params.require(:promotion).permit(:title, :description, :discount_percentage, :start_date, :end_date, :establishment_id)
  end
end
