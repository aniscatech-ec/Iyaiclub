import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="refund-policy"
export default class extends Controller {
    static targets = ["container"]

  connect() {
      console.log("connected to refund controller")
  }

    add(event) {
        event.preventDefault()
        const inputGroup = document.createElement("div")
        inputGroup.classList.add("input-group", "mb-2")
        inputGroup.innerHTML = `
      <input type="text" name="pricing_policy[refund_policy][]" class="form-control" />
      <button type="button" class="btn btn-outline-danger" data-action="refund-policy#remove">Eliminar</button>
    `
        this.containerTarget.appendChild(inputGroup)
    }

    remove(event) {
        event.preventDefault()
        event.target.closest(".input-group").remove()
    }
}
