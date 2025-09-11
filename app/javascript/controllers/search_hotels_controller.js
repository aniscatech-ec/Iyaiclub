import { Controller } from "@hotwired/stimulus"

// Conectar con data-controller="search-hotels"
export default class extends Controller {
    static targets = ["adults", "children", "rooms", "guestsSummary", "amenitiesSummary", "amenity"]

    connect() {
        // Limpieza de backdrops extra cada vez que Turbo carga
        document.addEventListener("turbo:load", this.cleanupBackdrops)
        document.addEventListener("hidden.bs.modal", this.cleanupBackdrops)
    }

    disconnect() {
        document.removeEventListener("turbo:load", this.cleanupBackdrops)
        document.removeEventListener("hidden.bs.modal", this.cleanupBackdrops)
    }

    cleanupBackdrops() {
        document.querySelectorAll(".modal-backdrop").forEach(el => el.remove())
        document.body.classList.remove("modal-open")
        document.body.style.overflow = ""
    }

    // ----------- Huéspedes -----------
    updateGuests(event) {
        const type = event.target.dataset.type
        const change = parseInt(event.target.dataset.change)
        const input = this[`${type}Target`]

        let value = parseInt(input.value) + change
        if (type === "adults" || type === "rooms") {
            if (value < 1) value = 1
        } else if (value < 0) value = 0
        input.value = value
    }

    applyGuests() {
        const adults = parseInt(this.adultsTarget.value)
        const children = parseInt(this.childrenTarget.value)
        const rooms = parseInt(this.roomsTarget.value)

        let summary = `${adults} adulto${adults != 1 ? "s" : ""}`
        if (children > 0) summary += ` · ${children} niño${children != 1 ? "s" : ""}`
        summary += ` · ${rooms} habitación${rooms != 1 ? "es" : ""}`

        this.guestsSummaryTarget.innerHTML = `<i class="bi bi-people me-2"></i> ${summary}`
    }

    // ----------- Comodidades -----------
    applyAmenities() {
        const selected = this.amenityTargets.filter(cb => cb.checked).map(cb => cb.value)

        let summary = `<i class="bi bi-star me-2"></i> Seleccionar`
        if (selected.length > 0) {
            if (selected.length <= 3) {
                summary = `<i class="bi bi-star me-2"></i> ${selected.join(" · ")}`
            } else {
                summary = `<i class="bi bi-star me-2"></i> ${selected.length} comodidades seleccionadas`
            }
        }

        this.amenitiesSummaryTarget.innerHTML = summary
    }
}
