class PayphoneService
  BASE_URL = "https://pay.payphonetodoesposible.com/api".freeze

  def initialize
    @token = ENV.fetch("PAYPHONE_TOKEN")
    @store_id = ENV.fetch("PAYPHONE_STORE_ID")
  end

  # Prepara una transacción y retorna las URLs de pago de PayPhone.
  # amount_cents: monto total en centavos (ej: $10.00 = 1000)
  # client_transaction_id: ID único generado por la app
  # response_url: URL a la que PayPhone redirige tras el pago
  # cancel_url: URL a la que PayPhone redirige si se cancela
  def prepare(amount_cents:, client_transaction_id:, response_url:, cancel_url: nil, reference: "", **opts)
    body = {
      amount: amount_cents,
      amountWithoutTax: amount_cents,
      clientTransactionId: client_transaction_id,
      responseUrl: response_url,
      cancellationUrl: cancel_url,
      storeId: @store_id,
      currency: "USD",
      reference: reference
    }.merge(opts.slice(:email, :phoneNumber, :documentId))

    post("/button/Prepare", body)
  end

  # Confirma una transacción después de que el usuario completó el pago.
  # id: ID de transacción PayPhone (recibido en el callback)
  # client_tx_id: clientTransactionId original
  def confirm(id:, client_tx_id:)
    body = {
      id: id,
      clientTxId: client_tx_id
    }

    post("/button/V2/Confirm", body)
  end

  private

  def post(path, body)
    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@token}"
    request["Content-Type"] = "application/json"
    request.body = body.compact.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess)
      { success: true, data: parsed }
    else
      { success: false, error: parsed["message"] || "Error en PayPhone", data: parsed }
    end
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    { success: false, error: "Timeout al conectar con PayPhone: #{e.message}" }
  rescue JSON::ParserError
    { success: false, error: "Respuesta inválida de PayPhone" }
  rescue StandardError => e
    { success: false, error: "Error inesperado: #{e.message}" }
  end
end
