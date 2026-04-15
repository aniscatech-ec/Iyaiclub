import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vendedorSection"]

  connect() {
    this.toggleVendedores()
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
}
