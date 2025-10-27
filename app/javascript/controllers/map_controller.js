import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Conecta este controlador a <div data-controller="map">
export default class extends Controller {
    static targets = ["latitude", "longitude"]

    connect() {
        console.log("Connected to the map")
        console.log("Leaflet cargado ✅")

        const defaultLat = -0.180653
        const defaultLng = -78.467834

        const map = L.map("map").setView([defaultLat, defaultLng], 13)

        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map)

        let marker = L.marker([defaultLat, defaultLng], { draggable: true }).addTo(map)

        const updateLatLng = (lat, lng) => {
            this.latitudeTarget.value = lat.toFixed(6)
            this.longitudeTarget.value = lng.toFixed(6)
        }

        updateLatLng(defaultLat, defaultLng)

        marker.on("moveend", (e) => {
            const { lat, lng } = e.target.getLatLng()
            updateLatLng(lat, lng)
        })

        map.on("click", (e) => {
            marker.setLatLng(e.latlng)
            updateLatLng(e.latlng.lat, e.latlng.lng)
        })

        // 🌍 Detectar ubicación real del usuario
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (pos) => {
                    const lat = pos.coords.latitude
                    const lng = pos.coords.longitude
                    console.log(`Ubicación detectada: ${lat}, ${lng}`)

                    map.setView([lat, lng], 15)
                    marker.setLatLng([lat, lng])
                    updateLatLng(lat, lng)

                    // Agrega un círculo alrededor de tu ubicación (opcional)
                    L.circle([lat, lng], { radius: 100, color: "blue", fillOpacity: 0.2 }).addTo(map)
                },
                (err) => {
                    console.warn("No se pudo obtener ubicación: ", err.message)
                }
            )
        } else {
            console.warn("Geolocalización no soportada por este navegador.")
        }
    }
}
