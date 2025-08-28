import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
    static targets = ["input", "results"]

    search() {
        let query = this.inputTarget.value
        if (query.length < 2) {
            this.resultsTarget.innerHTML = ""
            return
        }

        fetch(`/cities/autocomplete?q=${query}`)
            .then(r => r.json())
            .then(data => {
                this.resultsTarget.innerHTML = data.map(name =>
                    `<button type="button" class="list-group-item list-group-item-action"
                   data-action="click->autocomplete#select"
                   data-value="${name}">${name}</button>`
                ).join("")
            })
    }

    select(e) {
        this.inputTarget.value = e.target.dataset.value
        this.resultsTarget.innerHTML = ""
    }
}