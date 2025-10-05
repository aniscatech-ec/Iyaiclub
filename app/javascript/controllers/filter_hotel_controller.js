import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "hotelsContainer", "checkbox", "resultsCount",
        "minPrice", "maxPrice", "minPriceValue", "maxPriceValue"
    ]

    connect() {
        // Inicializar valores de etiquetas
        if (this.hasMinPriceTarget && this.hasMaxPriceTarget) {
            this.minPriceValueTarget.textContent = this.minPriceTarget.value
            this.maxPriceValueTarget.textContent = this.maxPriceTarget.value

            this.minPriceTarget.addEventListener("input", () => this.updateSliderVisuals())
            this.maxPriceTarget.addEventListener("input", () => this.updateSliderVisuals())
        }

        // Checkboxes
        this.checkboxTargets.forEach(cb => cb.addEventListener("change", () => this.applyFilters()))
    }

    updateSliderVisuals() {
        const min = parseInt(this.minPriceTarget.value)
        const max = parseInt(this.maxPriceTarget.value)
        if (min > max) {
            // Opcional: evitar que min supere max
            this.minPriceTarget.value = max
        }

        this.minPriceValueTarget.textContent = this.minPriceTarget.value
        this.maxPriceValueTarget.textContent = this.maxPriceTarget.value

        // Actualiza la parte coloreada del slider entre min y max
        const wrapper = this.minPriceTarget.closest(".range-wrapper")
        const track = wrapper.querySelector(".slider-track")
        const rangeDiv = wrapper.querySelector(".slider-range")

        const total = this.minPriceTarget.max - this.minPriceTarget.min
        const leftPerc = ((this.minPriceTarget.value - this.minPriceTarget.min) / total) * 100
        const rightPerc = 100 - ((this.maxPriceTarget.value - this.minPriceTarget.min) / total) * 100

        rangeDiv.style.left = leftPerc + "%"
        rangeDiv.style.right = rightPerc + "%"
    }

    buildParams() {
        const params = new URLSearchParams()

        // amenities seleccionadas
        const selected = this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)
        selected.forEach(id => params.append("amenities[]", id))

        // precio
        if (this.hasMinPriceTarget && this.hasMaxPriceTarget) {
            params.append("min_price", this.minPriceTarget.value)
            params.append("max_price", this.maxPriceTarget.value)
        }

        return params.toString()
    }

    async applyFilters() {
        const qs = this.buildParams()
        const url = `/hotels?${qs}`
        this.resultsCountTarget.textContent = "Cargando..."
        this.hotelsContainerTarget.innerHTML = "<p class='text-center p-3'>Cargando hoteles...</p>"

        const res = await fetch(url, { headers: { "X-Requested-With": "XMLHttpRequest" } })
        if (res.ok) {
            const html = await res.text()
            this.hotelsContainerTarget.innerHTML = html
            const count = this.hotelsContainerTarget.querySelectorAll(".hotel-card").length
            this.resultsCountTarget.textContent = `${count} hoteles encontrados`
            history.pushState(null, "", url)
        } else {
            this.resultsCountTarget.textContent = "Error"
            this.hotelsContainerTarget.innerHTML = "<p class='text-danger'>Error cargando hoteles</p>"
        }
    }

    filterByPrice() {
        this.applyFilters()
    }
}
