import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="policy"
export default class extends Controller {
    static targets = ["list", "item"]

  connect() {
        console.log("Connected to policy controller")
  }


    add() {
        const index = this.itemTargets.length
        const wrapper = document.createElement("div")
        wrapper.classList.add("input-group", "mb-2")
        wrapper.setAttribute("data-policy-target", "item")

        wrapper.innerHTML = `
      <input type="text"
             name="establishment[policies][]"
             class="form-control"
             placeholder="Ej: Nueva política" />
      <button type="button"
              class="btn btn-outline-danger"
              data-action="click->policy#remove">
        ✕
      </button>
    `

        this.listTarget.appendChild(wrapper)
    }

    remove(event) {
        event.target.closest("[data-policy-target='item']").remove()
    }
}
