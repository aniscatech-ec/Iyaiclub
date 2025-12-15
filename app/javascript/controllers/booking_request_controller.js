import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        establishmentId: Number,
        source: String
    }

    connect() {
        console.log("CONECTADO")
        this.element.addEventListener("click", () => {
            this.register()
        })
    }

    register() {
        fetch("/booking_requests", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document
                    .querySelector("meta[name='csrf-token']")
                    .content
            },
            body: JSON.stringify({
                establishment_id: this.establishmentIdValue,
                source: this.sourceValue
            })
        })
    }
}
