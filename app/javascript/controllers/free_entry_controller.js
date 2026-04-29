import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "priceWrapper",
    "priceField",
    "legalCard",
    "legalRequiredGroup",
    "legalRequiredField",
    "legalOptionalField",
    "optionalNote"
  ]

  connect() {
    const checkbox = this.element.querySelector("#getaway_free_entry")
    if (checkbox) this.applyState(checkbox.checked)
  }

  toggle(event) {
    this.applyState(event.target.checked)
  }

  applyState(free) {
    // Price field
    if (this.hasPriceWrapperTarget) {
      this.priceWrapperTarget.style.display = free ? "none" : ""
    }
    if (this.hasPriceFieldTarget) {
      this.priceFieldTarget.disabled = free
      this.priceFieldTarget.required = !free
      if (free) this.priceFieldTarget.value = "0"
    }

    // Legal card opacity hint
    if (this.hasLegalCardTarget) {
      this.legalCardTarget.style.opacity = free ? "0.55" : ""
    }

    // Required legal fields (representante, documento, contacto)
    this.legalRequiredFieldTargets.forEach(el => {
      el.disabled = free
      el.required = !free
    })

    // Required-group label classes
    this.legalRequiredGroupTargets.forEach(group => {
      group.querySelectorAll(".form-label").forEach(label => {
        label.classList.toggle("required-field", !free)
      })
    })

    // Optional business_name
    this.legalOptionalFieldTargets.forEach(el => {
      el.disabled = free
      el.required = false
    })

    // Optional note visibility
    this.optionalNoteTargets.forEach(el => {
      el.style.display = free ? "" : "none"
    })
  }
}
