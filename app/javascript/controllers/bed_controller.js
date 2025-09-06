import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
    static targets = ["container", "template"]

    connect() {
        console.log("Location controller conectado ✅")
    }


    addField(event) {
        event.preventDefault()
        let content = this.templateTarget.innerHTML
        this.containerTarget.insertAdjacentHTML("beforeend", content)
    }

    removeField(event) {
        event.preventDefault()
        event.target.closest(".bed-row").remove()
    }
}
