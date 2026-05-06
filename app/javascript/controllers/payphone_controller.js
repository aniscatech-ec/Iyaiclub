import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    token: String,
    storeId: String,
    amount: Number,
    clientTransactionId: String,
    reference: String,
    email: String
  }

  connect() {
    this._showLoading()

    // Si el SDK ya está cargado, inicializar directo
    if (typeof PPaymentButtonBox !== "undefined") {
      this.initPaymentBox()
      return
    }

    // Inyectar el script dinámicamente — nunca depender de tags estáticos
    this.loadSDK()
  }

  disconnect() {
    if (this._pollTimer) clearTimeout(this._pollTimer)
  }

  loadSDK() {
    // Evitar inyectar CSS duplicado
    if (!document.querySelector('link[href*="payphonetodoesposible.com"]')) {
      const link = document.createElement("link")
      link.rel = "stylesheet"
      link.href = "https://cdn.payphonetodoesposible.com/box/v1.1/payphone-payment-box.css"
      document.head.appendChild(link)
    }

    // Si el script ya está en el DOM (de una navegación previa), eliminarlo primero
    // para forzar una recarga limpia y asegurar que onload dispare
    const existing = document.querySelector('script[src*="payphonetodoesposible.com"]')
    if (existing) existing.remove()

    const script = document.createElement("script")
    script.src = "https://cdn.payphonetodoesposible.com/box/v1.1/payphone-payment-box.js"
    script.onload = () => this.initPaymentBox()
    script.onerror = () => this._showError("No se pudo cargar el módulo de pago. Recarga la página.")
    document.head.appendChild(script)
  }

  initPaymentBox() {
    const btn = document.getElementById("pp-button")
    if (!btn) {
      this._showError("Error interno: contenedor de pago no encontrado.")
      return
    }

    const config = {
      token: this.tokenValue,
      clientTransactionId: this.clientTransactionIdValue,
      amount: this.amountValue,
      amountWithoutTax: this.amountValue,
      currency: "USD",
      storeId: this.storeIdValue,
      reference: this.referenceValue,
      lang: "es",
      defaultMethod: "card"
    }

    if (this.emailValue && this.emailValue.trim() !== "") config.email = this.emailValue

    try {
      new PPaymentButtonBox(config).render("pp-button")
      this._hideLoading()
    } catch(e) {
      console.error("PayPhone render error:", e)
      this._showError("Error al inicializar el pago. Recarga la página.")
    }
  }

  _showLoading() {
    const btn = document.getElementById("pp-button")
    if (btn) btn.innerHTML = '<div class="text-muted py-3"><i class="fas fa-spinner fa-spin me-2"></i>Cargando módulo de pago...</div>'
  }

  _hideLoading() {
    // El SDK reemplaza el contenido del div, no se necesita hacer nada
  }

  _showError(msg) {
    const btn = document.getElementById("pp-button")
    if (btn) btn.innerHTML = `<div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i>${msg}</div>`
  }
}
