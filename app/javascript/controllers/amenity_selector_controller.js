import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["checkbox"]

    connect() {
        // Al cargar, marcar visualmente los cards que ya están seleccionados
        this.checkboxTargets.forEach(checkbox => {
            const card = checkbox.closest(".form-check")
            if (checkbox.checked) {
                card.classList.add("selected")
            }
        })
    }

    toggle(event) {
        const card = event.currentTarget
        const checkbox = card.querySelector("input[type=checkbox]")

        // Cambiar estado del checkbox
        checkbox.checked = !checkbox.checked

        // Agregar o quitar clase 'selected' al div
        card.classList.toggle("selected", checkbox.checked)
    }
}
