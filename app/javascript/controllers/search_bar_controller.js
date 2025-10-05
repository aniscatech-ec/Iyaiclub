// app/javascript/controllers/search_bar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["selectedEstablishment", "establishmentInput"]

    connect() {
        console.log("SearchBarController conectado")
    }

    // Acción para manejar la selección del dropdown
    selectEstablishment(event) {
        event.preventDefault()

        const item = event.currentTarget
        const value = item.dataset.value
        const html = item.innerHTML

        // Actualiza el botón principal con el ítem seleccionado
        this.selectedEstablishmentTarget.innerHTML = html

        // Actualiza el input oculto que se enviará al backend
        this.establishmentInputTarget.value = value
    }
}

