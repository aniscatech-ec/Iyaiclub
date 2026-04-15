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
    this.initPaymentBox()
  }

  initPaymentBox() {
    // Esperar a que el SDK de PayPhone esté disponible
    if (typeof PPaymentButtonBox === "undefined") {
      setTimeout(() => this.initPaymentBox(), 100)
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

    if (this.emailValue) config.email = this.emailValue
    if (this.phoneValue) config.phoneNumber = this.phoneValue

    new PPaymentButtonBox(config).render("pp-button")
  }
}
