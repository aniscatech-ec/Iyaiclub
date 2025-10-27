import {Controller} from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
    static values = {
        lat: Number,
        lng: Number
    }

    connect() {
        if (!this.latValue || !this.lngValue) {
            console.warn("No hay coordenadas para mostrar el mapa")
            return
        }

        console.log("🗺️ Controlador map-show conectado")

        const lat = this.latValue
        const lng = this.lngValue

        // Crear el mapa
        const map = L.map(this.element).setView([lat, lng], 14)

        // Capa base OpenStreetMap
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map)

        // Marcador con popup
        const marker = L.marker([lat, lng]).addTo(map)
        // marker.bindPopup(`Ubicación del hotel<br>Lat: ${lat}, Lng: ${lng}`).openPopup()
        marker.bindPopup(`
  Ubicación del hotel<br>
  Lat: ${lat}, Lng: ${lng}<br>
  <a href="https://www.google.com/maps/search/?api=1&query=${lat},${lng}" target="_blank" rel="noopener">
    Abrir en Google Maps
  </a>
`).openPopup()

        // Abrir Google Maps al hacer click en el marcador
        // marker.on("click", () => {
        //     const url = `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`
        //     window.open(url, "_blank", "noopener")
        // })
    }
}
