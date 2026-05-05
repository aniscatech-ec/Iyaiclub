class ReviewsController < ApplicationController
  before_action :set_establishment
  before_action :set_review, only: [:destroy]

  def create
    @review = @establishment.reviews.build(review_params)
    
    if @review.save
      redirect_to @establishment, notice: 'La reseña fue creada exitosamente.'
    else
      redirect_to @establishment, alert: 'No se pudo crear la reseña. Por favor verifica los datos.'
    end
  end

  def destroy
    @review.destroy
    redirect_to @establishment, notice: 'La reseña fue eliminada exitosamente.'
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id])
  end

  def set_review
    @review = @establishment.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :user_name)
  end
end
