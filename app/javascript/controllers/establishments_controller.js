import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "form", "list", "spinner", "count",
        "minInput", "maxInput", "minLabel", "maxLabel",
        "input", "cityAlert"
    ]

    connect() {
        this.updateLabels()
        this.inputTargets.forEach(input => {
            input.addEventListener("input", () => this.updateLabels())
            input.addEventListener("input", () => this.debounce(this.applyFilters.bind(this)))
            input.addEventListener("change", () => this.debounce(this.applyFilters.bind(this)))
        })
        this.setupPaginationLinks()
        this.animateCards()
    }

    updateLabels() {
        if (this.hasMinInputTarget && this.hasMinLabelTarget) this.minLabelTarget.textContent = this.minInputTarget.value
        if (this.hasMaxInputTarget && this.hasMaxLabelTarget) this.maxLabelTarget.textContent = this.maxInputTarget.value
    }

    debounce(fn, delay = 300) {
        clearTimeout(this.debounceTimeout)
        this.debounceTimeout = setTimeout(fn, delay)
    }

    toggleLoading(show) {
        if (show) {
            this.spinnerTarget.classList.remove("d-none")
            this.listTarget.classList.add("fade-out")
        } else {
            this.spinnerTarget.classList.add("d-none")
            this.listTarget.classList.remove("fade-out")
        }
    }

    animateCards() {
        this.listTarget.querySelectorAll(".establishment-card").forEach((card, idx) => {
            setTimeout(() => card.classList.add("visible"), idx * 100)
        })
    }

    applyFilters() {
        const formData = new FormData(this.formTarget)
        if (this.hasMinInputTarget) formData.set("min_price", this.minInputTarget.value)
        if (this.hasMaxInputTarget) formData.set("max_price", this.maxInputTarget.value)
        const queryString = new URLSearchParams(formData).toString()
        const url = `/establishments?${queryString}`

        this.toggleLoading(true)

        fetch(url, {headers: {"Accept": "text/html"}})
            .then(res => res.text())
            .then(html => {
                const doc = new DOMParser().parseFromString(html, "text/html")
                const newList = doc.getElementById("establishments-list")
                const newCount = doc.getElementById("results-count")
                if (newList) {
                    this.listTarget.innerHTML = newList.innerHTML
                    this.animateCards()
                    this.setupPaginationLinks()
                    const newAlert = doc.getElementById("city-alert")
                    if (newAlert && this.hasCityAlertTarget) {
                        this.cityAlertTarget.innerHTML = newAlert.innerHTML
                    }

                }
                if (newCount) this.countTarget.textContent = newCount.textContent
            })
            .catch(err => console.error("Error al cargar filtros:", err))
            .finally(() => this.toggleLoading(false))
    }

    setupPaginationLinks() {
        this.listTarget.querySelectorAll(".pagination a").forEach(link => {
            link.addEventListener("click", e => {
                e.preventDefault()
                this.toggleLoading(true)
                fetch(link.href, {headers: {"Accept": "text/html"}})
                    .then(res => res.text())
                    .then(html => {
                        const doc = new DOMParser().parseFromString(html, "text/html")
                        const newList = doc.getElementById("establishments-list")
                        if (newList) {
                            this.listTarget.innerHTML = newList.innerHTML
                            this.animateCards()
                            this.setupPaginationLinks()
                        }
                    })
                    .finally(() => this.toggleLoading(false))
            })
        })
    }
}
