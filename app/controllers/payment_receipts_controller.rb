class PaymentReceiptsController < ApplicationController
  before_action :set_subscription

  def index
  end

  def new
    @payment_receipt = PaymentReceipt.new
  end
  def show
  end

  def edit
  end

  def create
    @payment_receipt = PaymentReceipt.new(payment_receipt_params)
    @payment_receipt.subscription = @subscription
    @payment_receipt.user = current_user  # quien subió el comprobante
    @payment_receipt.status = :pendiente

    if @payment_receipt.save
      redirect_to @subscription, notice: "Comprobante enviado con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    @payment_receipt = PaymentReceipt.find(params[:id])
    @payment_receipt.update(status: :aprobado)

    # si quieres activar la subscripción automáticamente:
    @payment_receipt.subscription.update(status: :activada)

    # Activa la suscripción con fechas
    @payment_receipt.subscription.set_dates
    @payment_receipt.subscription.save

    redirect_to @payment_receipt.subscription, notice: "Comprobante aprobado."
  end

  def reject
    @payment_receipt = PaymentReceipt.find(params[:id])
    @payment_receipt.update(status: :rechazado)

    redirect_to @payment_receipt.subscription,
                alert: "Comprobante rechazado. El afiliado debe subir uno nuevo."
  end


  def set_subscription
    @subscription = Subscription.find(params[:subscription_id])
  end

  private
  def payment_receipt_params
    params.require(:payment_receipt).permit(:notes, :file)
  end

end
