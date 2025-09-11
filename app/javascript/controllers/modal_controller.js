// app/javascript/controllers/modal_cleanup_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Escucha los eventos de apertura/cierre de cualquier modal
        document.addEventListener("show.bs.modal", this.cleanupBackdrops)
        document.addEventListener("hidden.bs.modal", this.cleanupBackdrops)
        document.addEventListener("turbo:load", this.cleanupBackdrops)
    }

    disconnect() {
        document.removeEventListener("show.bs.modal", this.cleanupBackdrops)
        document.removeEventListener("hidden.bs.modal", this.cleanupBackdrops)
        document.removeEventListener("turbo:load", this.cleanupBackdrops)
    }

    cleanupBackdrops() {
        // Elimina cualquier backdrop sobrante
        document.querySelectorAll(".modal-backdrop").forEach(el => el.remove())
        // Asegura que el body no quede bloqueado
        document.body.classList.remove("modal-open")
        document.body.style.overflow = ""
        document.body.style.paddingRight = ""
    }
}
