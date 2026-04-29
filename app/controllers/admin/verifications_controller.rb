module Admin
  class VerificationsController < ApplicationController
    layout "dashboard"
    before_action :authenticate_user!
    before_action :authenticate_admin!
    before_action :set_verification, only: [:show, :approve, :reject]

    def index
      scope = Establishment.includes(:user, :verification, :country, :city)
                            .where.not(verifications: { id: nil })
                            .joins(:verification)

      # Filtro por estado (default: pendientes)
      status_filter = params[:status].presence || "pending"
      if status_filter == "all"
        # sin filtro de estado
      else
        scope = scope.where(approval_status: Establishment.approval_statuses[status_filter] || 0)
      end

      # Filtro por tipo de establecimiento
      if params[:category].present?
        scope = scope.where(category: params[:category])
      end

      # Filtro por afiliado (user_id)
      if params[:user_id].present?
        scope = scope.where(user_id: params[:user_id])
      end

      # Búsqueda por nombre de establecimiento o nombre de afiliado
      if params[:q].present?
        q = "%#{params[:q].strip}%"
        scope = scope.where("establishments.name ILIKE :q OR users.name ILIKE :q OR users.email ILIKE :q", q: q)
      end

      @establishments = scope.order(created_at: :desc)
      @afiliados       = User.where(role: :afiliado).order(:name)
      @status_filter   = status_filter
    end

    def show
      @establishment = @verification.establishment
      @owner         = @establishment.user
    end

    def approve
      @establishment = @verification.establishment
      ActiveRecord::Base.transaction do
        @verification.update!(status: :approved, verified_at: Time.current, reviewed_by_id: current_user.id)
        @establishment.update!(approval_status: :approved, approved_at: Time.current,
                               approved_by_id: current_user.id, status: :active)
      end
      # TODO: send approval email to owner
      redirect_to admin_verifications_path, notice: "Establecimiento \"#{@establishment.name}\" aprobado correctamente."
    rescue => e
      redirect_to admin_verification_path(@verification), alert: "Error al aprobar: #{e.message}"
    end

    def reject
      rejection_notes = params[:rejection_notes].to_s.strip
      if rejection_notes.blank?
        redirect_to admin_verification_path(@verification), alert: "Debes ingresar un motivo de rechazo."
        return
      end
      @establishment = @verification.establishment
      ActiveRecord::Base.transaction do
        @verification.update!(status: :rejected, reviewer_notes: rejection_notes, reviewed_by_id: current_user.id)
        @establishment.update!(approval_status: :rejected, approval_notes: rejection_notes)
      end
      # TODO: send rejection email to owner with notes
      redirect_to admin_verifications_path, notice: "Establecimiento \"#{@establishment.name}\" rechazado."
    rescue => e
      redirect_to admin_verification_path(@verification), alert: "Error al rechazar: #{e.message}"
    end

    private

    def set_verification
      @verification = Verification.includes(establishment: [:user, :country, :city, :province]).find(params[:id])
    end
  end
end
