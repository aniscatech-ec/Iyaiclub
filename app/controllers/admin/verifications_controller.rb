module Admin
  class VerificationsController < ApplicationController
    layout "dashboard"
    before_action :authenticate_user!
    # before_action :verify_admin! # assuming there is some admin authorization if needed, we'll keep it simple as user asked

    before_action :set_verification, only: [:show, :approve, :reject]

    def index
      @verifications = Verification.includes(:establishment).where(status: :pending)
    end

    def show
    end

    def approve
      if @verification.update(status: :approved, verified_at: Time.current)
        flash[:notice] = "Establishment approved"
        redirect_to admin_verifications_path
      else
        flash[:alert] = "Error approving establishment"
        render :show
      end
    end

    def reject
      if @verification.update(status: :rejected, reviewer_notes: params[:reviewer_notes])
        flash[:notice] = "Establishment rejected"
        redirect_to admin_verifications_path
      else
        flash[:alert] = "Error rejecting establishment"
        render :show
      end
    end

    private

    def set_verification
      @verification = Verification.find(params[:id])
    end
  end
end
