import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-user"
// Handles country → city dependent dropdowns (no province step).
// Pass data-location-user-saved-city-id-value on the wrapper to restore a pre-selected city.
export default class extends Controller {
    static targets = ["country", "city"]
    static values  = { savedCityId: String }

    connect() {
        // Pre-load cities if a country is already selected (edit forms)
        const countryId = this.countryTarget.value
        if (countryId) {
            this._loadCities(countryId, this.savedCityIdValue || null)
        }
    }

    // Fired when the country select changes
    updateCities(event) {
        const countryId = event.target.value

        if (!countryId) {
            this.cityTarget.innerHTML = "<option value=''>Seleccionar ciudad</option>"
            return
        }

        this._loadCities(countryId, null)
    }

    _loadCities(countryId, restoreCityId) {
        const url = `/locations/country_cities/${countryId}`

        fetch(url)
            .then(response => {
                if (!response.ok) throw new Error(`HTTP ${response.status}`)
                return response.json()
            })
            .then(data => {
                const options = ['<option value="">Seleccionar ciudad</option>']
                data.forEach(city => {
                    const selected = restoreCityId && String(city.id) === String(restoreCityId) ? " selected" : ""
                    options.push(`<option value="${city.id}"${selected}>${city.name}</option>`)
                })
                this.cityTarget.innerHTML = options.join("")
            })
            .catch(error => console.error("Error cargando ciudades:", error))
    }
}
