import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vendedorSection", "quantityInput", "totalPrice", "submitButton"]

  connect() {
    this.toggleVendedores()
    this.unitPrice = parseFloat(this.data.get("unitPrice")) || 0
  }

  toggleVendedores() {
    const selected = this.element.querySelector('input[name="payment_method"]:checked')
    if (!selected || !this.hasVendedorSectionTarget) return

    if (selected.value === "transferencia") {
      this.vendedorSectionTarget.style.display = "block"
      // Hacer vendedor_id requerido
      this.vendedorSectionTarget.querySelectorAll('input[name="vendedor_id"]').forEach(input => {
        input.required = true
      })
    } else {
      this.vendedorSectionTarget.style.display = "none"
      this.vendedorSectionTarget.querySelectorAll('input[name="vendedor_id"]').forEach(input => {
        input.required = false
      })
    }
  }

  incrementQuantity() {
    const input = this.quantityInputTarget
    const currentValue = parseInt(input.value) || 1
    const maxValue = parseInt(input.max) || 10

    if (currentValue < maxValue) {
      input.value = currentValue + 1
      this.updateTotal()
    }
  }

  decrementQuantity() {
    const input = this.quantityInputTarget
    const currentValue = parseInt(input.value) || 1

    if (currentValue > 1) {
      input.value = currentValue - 1
      this.updateTotal()
    }
  }

  updateTotal() {
    const quantity = parseInt(this.quantityInputTarget.value) || 1
    const total = (this.unitPrice * quantity).toFixed(2)

    if (this.hasTotalPriceTarget) {
      this.totalPriceTarget.textContent = `$${total}`
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.innerHTML = `<i class="fas fa-shopping-cart me-1"></i> Continuar con el pago — $${total}`
    }
  }
}
