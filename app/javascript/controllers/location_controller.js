import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
    static targets = ["country", "province", "city"]

    connect() {
        console.log("Location controller conectado ✅")
        // if (navigator.geolocation) {
        //     navigator.geolocation.getCurrentPosition((pos) => {
        //         console.log("Lat:", pos.coords.latitude, "Lng:", pos.coords.longitude);
        //     });
        // }

    }

    updateCities(event) {
        const provinceId = event.target.value
        if (!provinceId) {
            this.cityTarget.innerHTML = "<option value=''>Seleccionar ciudad</option>"
            return
        }

        // URL para obtener las ciudades según la provincia
        const url = `/provinces/${provinceId}/cities.json`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                this.cityTarget.innerHTML = "<option value=''>Seleccionar ciudad</option>"
                data.forEach(city => {
                    const option = document.createElement("option")
                    option.value = city.id
                    option.textContent = city.name
                    this.cityTarget.appendChild(option)
                })
            })
            .catch(error => console.error("Error cargando ciudades:", error))
    }

    updateProvinces(event) {
        const countryId = event.target.value

        if (!countryId) {
            this.provinceTarget.innerHTML = '<option value="">Seleccionar provincia</option>'
            return
        }
        const url = `/countries/${countryId}/provinces.json`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                this.provinceTarget.innerHTML = '<option value="">Seleccionar provincia</option>'
                data.forEach(province => {
                    const option = document.createElement('option')
                    option.value = province.id
                    option.textContent = province.name
                    this.provinceTarget.appendChild(option)
                })
            })
    }
}
