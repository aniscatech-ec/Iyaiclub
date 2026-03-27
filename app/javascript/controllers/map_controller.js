import { Controller } from "@hotwired/stimulus"

// Conecta este controlador a <div data-controller="map">
export default class extends Controller {
    static targets = ["latitude", "longitude"]

    connect() {
        console.log("Connected to the map")

        const initMap = () => {
            if (typeof L === "undefined") {
                console.log("Leaflet todavía no está listo, reintentando...")
                setTimeout(initMap, 100) // reintenta cada 100ms
                return
            }

            console.log("Leaflet cargado ✅")

            const defaultLat = -0.180653
            const defaultLng = -78.467834

            const map = L.map("map").setView([defaultLat, defaultLng], 13)

            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                attribution: "&copy; OpenStreetMap contributors",
            }).addTo(map)

            let marker = L.marker([defaultLat, defaultLng], { draggable: true }).addTo(map)

            const updateLatLng = (lat, lng) => {
                document.getElementById("latitude").value = lat
                document.getElementById("longitude").value = lng
            }

            updateLatLng(defaultLat, defaultLng)

            // Cuando se mueve el marcador
            marker.on("moveend", (e) => {
                const { lat, lng } = e.target.getLatLng()
                updateLatLng(lat, lng)
            })

            // Cuando se hace click en el mapa
            map.on("click", (e) => {
                marker.setLatLng(e.latlng)
                updateLatLng(e.latlng.lat, e.latlng.lng)
            })

            // Detectar ubicación del usuario
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition((pos) => {
                    const lat = pos.coords.latitude
                    const lng = pos.coords.longitude
                    map.setView([lat, lng], 15)
                    marker.setLatLng([lat, lng])
                    updateLatLng(lat, lng)
                })
            }
        }

        // Llamamos al init
        initMap()
    }
}
