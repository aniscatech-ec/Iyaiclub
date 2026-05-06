class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_establishment
  before_action :authorize_turista!, only: [:create]
  before_action :set_review, only: [:destroy]
  before_action :authorize_destroy!, only: [:destroy]

  def create
    if current_user.reviews.exists?(establishment_id: @establishment.id)
      return redirect_to establishment_path(@establishment), alert: "Ya dejaste una reseña en este establecimiento."
    end

    @review = @establishment.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to establishment_path(@establishment), notice: "Tu reseña fue publicada correctamente."
    else
      redirect_to establishment_path(@establishment), alert: @review.errors.full_messages.first
    end
  end

  def destroy
    @review.destroy
    redirect_to establishment_path(@establishment), notice: "La reseña fue eliminada."
  end

  private

  def set_establishment
    @establishment = Establishment.find(params[:establishment_id])
  end

  def set_review
    @review = @establishment.reviews.find(params[:id])
  end

  def authorize_turista!
    unless current_user.turista?
      redirect_to establishment_path(@establishment), alert: "Solo los turistas pueden dejar reseñas."
    end
  end

  def authorize_destroy!
    unless current_user.administrador? || @review.user_id == current_user.id
      redirect_to establishment_path(@establishment), alert: "No tienes permiso para eliminar esta reseña."
    end
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
