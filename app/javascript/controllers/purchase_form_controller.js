import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vendedorSection", "quantityInput", "totalPrice", "submitButton", "comboBadge", "unitPriceDisplay"]

  connect() {
    this.toggleVendedores()
    this.basePrice     = parseFloat(this.data.get("unitPrice"))     || 0
    this.comboQuantity = parseInt(this.data.get("comboQuantity"))   || 0
    this.comboDiscount = parseFloat(this.data.get("comboDiscount")) || 0
    this.updateTotal()
  }

  toggleVendedores() {
    const selected = this.element.querySelector('input[name="payment_method"]:checked')
    if (!selected || !this.hasVendedorSectionTarget) return

    if (selected.value === "transferencia") {
      this.vendedorSectionTarget.style.display = "block"
      this.vendedorSectionTarget.querySelectorAll('select[name="vendedor_id"]').forEach(s => s.required = true)
    } else {
      this.vendedorSectionTarget.style.display = "none"
      this.vendedorSectionTarget.querySelectorAll('select[name="vendedor_id"]').forEach(s => s.required = false)
    }
  }

  incrementQuantity() {
    const input    = this.quantityInputTarget
    const current  = parseInt(input.value) || 1
    const maxValue = parseInt(input.max)   || 9999
    if (current < maxValue) {
      input.value = current + 1
      this.updateTotal()
    }
  }

  decrementQuantity() {
    const input   = this.quantityInputTarget
    const current = parseInt(input.value) || 1
    if (current > 1) {
      input.value = current - 1
      this.updateTotal()
    }
  }

  updateTotal() {
    const quantity    = parseInt(this.quantityInputTarget.value) || 1
    const comboActive   = this.comboQuantity > 0 && this.comboDiscount > 0 && quantity >= this.comboQuantity
    const subtotal      = this.basePrice * quantity
    const completeLots  = comboActive ? Math.floor(quantity / this.comboQuantity) : 0
    const total         = Math.max(subtotal - this.comboDiscount * completeLots, 0).toFixed(2)

    if (this.hasTotalPriceTarget) {
      this.totalPriceTarget.textContent = `$${total}`
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.innerHTML =
        `<i class="fas fa-shopping-cart me-1"></i> Continuar con el pago — $${total}`
    }

    if (this.hasUnitPriceDisplayTarget) {
      this.unitPriceDisplayTarget.textContent = `$${this.basePrice.toFixed(2)}`
    }

    if (this.hasComboBadgeTarget) {
      if (comboActive) {
        const saving = (this.comboDiscount * completeLots).toFixed(2)
        this.comboBadgeTarget.querySelector('[data-combo-saving]').textContent = `$${saving}`
        this.comboBadgeTarget.querySelector('[data-combo-lots]').textContent = completeLots
        this.comboBadgeTarget.style.display = "block"
      } else {
        this.comboBadgeTarget.style.display = "none"
      }
    }
  }
}
