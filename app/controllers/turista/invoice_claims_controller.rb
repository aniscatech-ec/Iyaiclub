class Turista::InvoiceClaimsController < ApplicationController
  before_action :authenticate_turista!
  layout "dashboard"

  def index
    @claims = current_user.invoice_claims.recent
  end

  def new
    @claim = InvoiceClaim.new
  end

  def create
    @claim = current_user.invoice_claims.build(claim_params)
    if @claim.save
      redirect_to turista_invoice_claims_path,
                  notice: "Factura enviada correctamente. Un administrador la revisará pronto."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def claim_params
    params.require(:invoice_claim).permit(
      :invoice_number, :amount, :description, :establishment_id, :invoice_file
    )
  end
end
