import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-user"
export default class extends Controller {
    static targets = ["country", "city"]

    connect() {
        console.log("Location-User controller conectado ✅")
    }

    // Método que se llama cuando cambia el país
    updateCities(event) {
        const countryId = event.target.value

        if (!countryId) {
            // Si no hay país seleccionado, limpiamos el select de ciudades
            this.cityTarget.innerHTML = "<option value=''>Seleccionar ciudad</option>"
            return
        }
        console.log("update cities " + countryId)

        // URL para obtener las ciudades del país
        const url = `/countries/${countryId}/cities.json`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                // Limpiar opciones previas
                this.cityTarget.innerHTML = "<option value=''>Seleccionar ciudad</option>"
                // Agregar las nuevas ciudades
                data.forEach(city => {
                    const option = document.createElement("option")
                    option.value = city.id
                    option.textContent = city.name
                    this.cityTarget.appendChild(option)
                })
            })
            .catch(error => console.error("Error cargando ciudades:", error))
    }
}
