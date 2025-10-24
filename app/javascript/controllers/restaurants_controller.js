import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form", "resultsContainer", "spinner", "resultsCount", "minInput", "maxInput", "minLabel", "maxLabel","cityAlert"]

    connect() {
        this.updatePriceLabels()
        this.setupEvents()
        this.setupPaginationLinks()
        this.animateCards()
    }

    setupEvents() {
        if (this.minInputTarget && this.minLabelTarget) {
            this.minInputTarget.addEventListener("input", () => this.updatePriceLabels())
        }
        if (this.maxInputTarget && this.maxLabelTarget) {
            this.maxInputTarget.addEventListener("input", () => this.updatePriceLabels())
        }

        const debouncedApplyFilters = this.debounce(() => this.applyFilters(), 300)
        this.formTarget.querySelectorAll("input, select").forEach(input => {
            input.addEventListener("input", debouncedApplyFilters)
            input.addEventListener("change", debouncedApplyFilters)
        })
    }

    updatePriceLabels() {
        if (this.minLabelTarget && this.minInputTarget)
            this.minLabelTarget.textContent = this.minInputTarget.value
        if (this.maxLabelTarget && this.maxInputTarget)
            this.maxLabelTarget.textContent = this.maxInputTarget.value
    }

    toggleLoading(show) {
        if (show) {
            this.spinnerTarget.classList.remove("d-none")
            this.resultsContainerTarget.classList.add("fade-out")
        } else {
            this.spinnerTarget.classList.add("d-none")
            this.resultsContainerTarget.classList.remove("fade-out")
        }
    }

    debounce(fn, delay = 300) {
        let timeout
        return (...args) => {
            clearTimeout(timeout)
            timeout = setTimeout(() => fn.apply(this, args), delay)
        }
    }

    applyFilters() {
        const formData = new FormData(this.formTarget)
        formData.set("min_price", this.minInputTarget.value)
        formData.set("max_price", this.maxInputTarget.value)

        const queryString = new URLSearchParams(formData).toString()
        this.toggleLoading(true)

        fetch(`/restaurants/search_results?${queryString}`, { headers: { "Accept": "text/html" } })
            .then(res => res.text())
            .then(html => {
                const doc = new DOMParser().parseFromString(html, "text/html")
                const newList = doc.getElementById("restaurants-list")
                const newCount = doc.getElementById("results-count")

                if (newList) {
                    this.resultsContainerTarget.innerHTML = newList.innerHTML
                    this.animateCards()
                    this.setupPaginationLinks()
                    const newAlert = doc.getElementById("city-alert")
                    if (newAlert && this.hasCityAlertTarget) {
                        this.cityAlertTarget.innerHTML = newAlert.innerHTML
                    }
                }
                if (newCount) this.resultsCountTarget.textContent = newCount.textContent
            })
            .catch(err => console.error("Error al cargar filtros:", err))
            .finally(() => this.toggleLoading(false))
    }

    setupPaginationLinks() {
        this.resultsContainerTarget.querySelectorAll(".pagination a").forEach(link => {
            link.addEventListener("click", e => {
                e.preventDefault()
                this.toggleLoading(true)
                fetch(link.href, { headers: { "Accept": "text/html" } })
                    .then(res => res.text())
                    .then(html => {
                        const doc = new DOMParser().parseFromString(html, "text/html")
                        const newList = doc.getElementById("restaurants-list")
                        if (newList) {
                            this.resultsContainerTarget.innerHTML = newList.innerHTML
                            this.animateCards()
                            this.setupPaginationLinks()
                        }
                    })
                    .finally(() => this.toggleLoading(false))
            })
        })
    }

    animateCards() {
        this.resultsContainerTarget.querySelectorAll(".establishment-card").forEach((card, idx) => {
            setTimeout(() => card.classList.add("visible"), idx * 100)
        })
    }
}
