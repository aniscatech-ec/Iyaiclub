import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Controlador para editar coordenadas en el formulario
export default class extends Controller {
    static targets = ["latitude", "longitude"]
    static values = { lat: Number, lng: Number }

    connect() {
        console.log("🗺️ Map Edit conectado")

        const lat = this.latValue || -0.180653
        const lng = this.lngValue || -78.467834

        // Crear mapa
        this.map = L.map(this.element).setView([lat, lng], 13)

        // Capa base
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(this.map)

        // Marcador
        this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map)

        // Inicializar inputs
        this.updateInputs(lat, lng)

        // Evento drag del marcador
        this.marker.on("moveend", (e) => {
            const { lat, lng } = e.target.getLatLng()
            this.updateInputs(lat, lng)
        })

        // Click en el mapa para mover marcador
        this.map.on("click", (e) => {
            this.marker.setLatLng(e.latlng)
            this.updateInputs(e.latlng.lat, e.latlng.lng)
        })

        // Botón para ubicar usuario
        // this.addLocateButton()
    }

    updateInputs(lat, lng) {
        this.latitudeTarget.value = lat.toFixed(6)
        this.longitudeTarget.value = lng.toFixed(6)
    }

    addLocateButton() {
        const locateBtn = L.control({ position: "topleft" })
        locateBtn.onAdd = () => {
            const button = L.DomUtil.create("button", "leaflet-bar")
            button.innerHTML = "📍"
            button.title = "Usar mi ubicación"
            button.style.backgroundColor = "white"
            button.style.cursor = "pointer"
            button.style.fontSize = "20px"
            button.onclick = () => this.locateUser()
            return button
        }
        locateBtn.addTo(this.map)
    }

    locateUser() {
        if (!navigator.geolocation) {
            alert("Tu navegador no soporta geolocalización 😞")
            return
        }

        navigator.geolocation.getCurrentPosition(
            (pos) => {
                const lat = pos.coords.latitude
                const lng = pos.coords.longitude
                this.map.setView([lat, lng], 15)
                this.marker.setLatLng([lat, lng])
                this.updateInputs(lat, lng)
            },
            (err) => {
                alert("No se pudo obtener tu ubicación. Intenta de nuevo.")
                console.warn(err)
            }
        )
    }
}
