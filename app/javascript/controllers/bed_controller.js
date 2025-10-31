import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "template"]
    static values = { unitId: String } // 👈 Recibe el ID único de la unidad

    connect() {
        console.log(`🛏️ Bed controller conectado para unidad ${this.unitIdValue}`)
    }

    addField(event) {
        event.preventDefault()

        // Insertar el template con los nombres corregidos
        let content = this.templateTarget.innerHTML

        // Reemplazar el marcador "UNIT_ID" dentro del template
        content = content.replaceAll("UNIT_ID", this.unitIdValue)

        this.containerTarget.insertAdjacentHTML("beforeend", content)
    }

    removeField(event) {
        event.preventDefault()
        event.target.closest(".bed-row").remove()
    }
}
