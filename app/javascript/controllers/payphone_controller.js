import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    token: String,
    storeId: String,
    amount: Number,
    clientTransactionId: String,
    reference: String,
    email: String,
    phone: String
  }

  connect() {
    // Si el SDK ya está cargado, inicializar directo
    if (typeof PPaymentButtonBox !== "undefined") {
      this.initPaymentBox()
      return
    }

    // Buscar el script tag del SDK en el documento
    const existingScript = document.querySelector(
      'script[src*="payphonetodoesposible.com"]'
    )

    if (existingScript) {
      // El script ya está en el DOM — esperar a que cargue
      existingScript.addEventListener("load", () => this.initPaymentBox())
      // Si ya cargó pero PPaymentButtonBox aún no está, hacer polling breve
      if (existingScript.readyState === "complete") {
        this.pollForSDK()
      }
    } else {
      // Inyectar el script dinámicamente y esperar
      this.loadSDK()
    }
  }

  disconnect() {
    if (this._pollTimer) clearTimeout(this._pollTimer)
  }

  loadSDK() {
    const link = document.createElement("link")
    link.rel = "stylesheet"
    link.href = "https://cdn.payphonetodoesposible.com/box/v1.1/payphone-payment-box.css"
    document.head.appendChild(link)

    const script = document.createElement("script")
    script.src = "https://cdn.payphonetodoesposible.com/box/v1.1/payphone-payment-box.js"
    script.onload = () => this.initPaymentBox()
    document.head.appendChild(script)
  }

  pollForSDK(attempts = 0) {
    if (typeof PPaymentButtonBox !== "undefined") {
      this.initPaymentBox()
      return
    }
    if (attempts > 50) {
      console.error("PayPhone SDK no cargó después de 5 segundos")
      return
    }
    this._pollTimer = setTimeout(() => this.pollForSDK(attempts + 1), 100)
  }

  initPaymentBox() {
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
    if (this.phoneValue && this.phoneValue.trim() !== "") config.phoneNumber = this.phoneValue

    new PPaymentButtonBox(config).render("pp-button")
  }
}
