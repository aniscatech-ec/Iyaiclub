class Admin::InvoiceClaimsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_claim, only: [:show, :approve, :reject]
  layout "dashboard"

  def index
    @claims = InvoiceClaim.includes(:user, :establishment, :reviewed_by).recent
    @claims = @claims.by_status(params[:status]) if params[:status].present?
  end

  def show
  end

  def approve
    points = params[:points_granted].to_i
    if points <= 0
      redirect_to admin_invoice_claim_path(@claim),
                  alert: "Debes ingresar un número de puntos válido."
      return
    end

    if @claim.approve!(admin: current_user, points: points, notes: params[:admin_notes])
      redirect_to admin_invoice_claims_path,
                  notice: "Factura aprobada. Se acreditaron #{points} puntos a #{@claim.user.name}."
    else
      redirect_to admin_invoice_claim_path(@claim),
                  alert: "No se pudo aprobar la factura."
    end
  end

  def reject
    if @claim.reject!(admin: current_user, notes: params[:admin_notes])
      redirect_to admin_invoice_claims_path,
                  notice: "Factura rechazada."
    else
      redirect_to admin_invoice_claim_path(@claim),
                  alert: "No se pudo rechazar la factura."
    end
  end

  private

  def set_claim
    @claim = InvoiceClaim.find(params[:id])
  end
end
