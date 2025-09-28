import { Controller } from "@hotwired/stimulus"

// Conecta con data-controller="affiliate"
export default class extends Controller {
    static targets = ["card", "search"]

    connect() {
        console.log("Affiliate controller conectado ✅")
    }

    filter() {
        const query = this.searchTarget.value.toLowerCase()
        this.cardTargets.forEach(card => {
            const name = card.dataset.name.toLowerCase()
            const email = card.dataset.email.toLowerCase()
            const phone = card.dataset.phone.toLowerCase()

            if (name.includes(query) || email.includes(query) || phone.includes(query)) {
                card.classList.remove("d-none")
            } else {
                card.classList.add("d-none")
            }
        })
    }

    select(e) {
        const card = e.currentTarget
        const url = card.dataset.url
        if (url) {
            window.location.href = url
        }
    }
}
