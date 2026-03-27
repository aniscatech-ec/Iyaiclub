import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["canvas"]
    static values = {
        latitude: Number,
        longitude: Number,
        name: String
    }

    connect() {
        this.initMap()
    }

    initMap() {
        if (typeof L === "undefined") {
            setTimeout(() => this.initMap(), 100)
            return
        }

        const lat = this.latitudeValue
        const lng = this.longitudeValue
        const name = this.nameValue

        const map = L.map(this.canvasTarget).setView([lat, lng], 15)

        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map)

        const marker = L.marker([lat, lng]).addTo(map)

        if (name) {
            marker.bindPopup(`<strong>${name}</strong>`).openPopup()
        }

        setTimeout(() => map.invalidateSize(), 200)
    }
}
