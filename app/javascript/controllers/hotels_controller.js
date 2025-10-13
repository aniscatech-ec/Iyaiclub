import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "form", "resultsContainer", "spinner", "resultsCount",
        "minInput", "maxInput", "minLabel", "maxLabel"
    ]

    connect() {
        this.debounceTimer = null
        this.setupListeners()
        this.setupPaginationLinks()
        this.animateCards()
    }

    setupListeners() {
        if (this.hasMinInputTarget && this.hasMinLabelTarget) {
            this.minInputTarget.addEventListener("input", () => this.minLabelTarget.textContent = this.minInputTarget.value)
        }
        if (this.hasMaxInputTarget && this.hasMaxLabelTarget) {
            this.maxInputTarget.addEventListener("input", () => this.maxLabelTarget.textContent = this.maxInputTarget.value)
        }

        if (this.hasFormTarget) {
            this.formTarget.querySelectorAll("input, select").forEach(input => {
                input.addEventListener("input", () => this.debounce(this.applyFilters.bind(this), 300))
                input.addEventListener("change", () => this.debounce(this.applyFilters.bind(this), 300))
            })
        }
    }

    debounce(fn, delay = 300) {
        clearTimeout(this.debounceTimer)
        this.debounceTimer = setTimeout(fn, delay)
    }

    toggleLoading(show) {
        if (!this.hasSpinnerTarget || !this.hasResultsContainerTarget) return
        if (show) {
            this.spinnerTarget.classList.remove("d-none")
            this.resultsContainerTarget.classList.add("fade-out")
        } else {
            this.spinnerTarget.classList.add("d-none")
            this.resultsContainerTarget.classList.remove("fade-out")
        }
    }

    animateCards() {
        if (!this.hasResultsContainerTarget) return
        this.resultsContainerTarget.querySelectorAll(".establishment-card").forEach((card, idx) => {
            setTimeout(() => card.classList.add("visible"), idx * 100)
        })
    }

    applyFilters() {
        if (!this.hasFormTarget) return

        const formData = new FormData(this.formTarget)
        if (this.hasMinInputTarget && this.hasMaxInputTarget) {
            formData.set("min_price", this.minInputTarget.value)
            formData.set("max_price", this.maxInputTarget.value)
        }

        const queryString = new URLSearchParams(formData).toString()
        this.toggleLoading(true)

        fetch(`/hotels?${queryString}`, { headers: { "Accept": "text/html" } })
            .then(res => res.text())
            .then(html => {
                const doc = new DOMParser().parseFromString(html, "text/html")
                const newList = doc.getElementById("hotels-list")
                const newCount = doc.getElementById("results-count")
                if (newList && this.hasResultsContainerTarget) {
                    this.resultsContainerTarget.innerHTML = newList.innerHTML
                    this.animateCards()
                    this.setupPaginationLinks()
                }
                if (newCount && this.hasResultsCountTarget) {
                    this.resultsCountTarget.textContent = newCount.textContent
                }
            })
            .catch(err => console.error("Error al cargar filtros:", err))
            .finally(() => this.toggleLoading(false))
    }

    setupPaginationLinks() {
        if (!this.hasResultsContainerTarget) return
        this.resultsContainerTarget.querySelectorAll(".pagination a").forEach(link => {
            link.addEventListener("click", e => {
                e.preventDefault()
                this.toggleLoading(true)
                fetch(link.href, { headers: { "Accept": "text/html" } })
                    .then(res => res.text())
                    .then(html => {
                        const doc = new DOMParser().parseFromString(html, "text/html")
                        const newList = doc.getElementById("hotels-list")
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
}
