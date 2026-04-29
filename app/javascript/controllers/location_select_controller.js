import { Controller } from "@hotwired/stimulus"

// Maneja los selectores dependientes País → Provincia → Ciudad.
//
// Uso en HTML:
//   <div data-controller="location-select"
//        data-location-select-country-id="establishment_country_id"
//        data-location-select-province-id="establishment_province_id"
//        data-location-select-city-id="establishment_city_id">
//
// El controller detecta los valores pre-seleccionados y restaura la cadena
// completa al cargar, sin disparar el evento change entre pasos intermedios.

export default class extends Controller {
  static values = {
    countryId:  String,
    provinceId: String,
    cityId:     String
  }

  connect() {
    this._loading = false   // flag para suprimir el listener de change durante la carga

    this.countryEl  = document.getElementById(this.countryIdValue)
    this.provinceEl = document.getElementById(this.provinceIdValue)
    this.cityEl     = document.getElementById(this.cityIdValue)

    if (!this.countryEl || !this.provinceEl || !this.cityEl) return

    // Guardar los valores pre-seleccionados ANTES de que el JS los toque
    this._savedProvinceId = this.provinceEl.value || null
    this._savedCityId     = this.cityEl.value     || null

    this.countryEl.addEventListener("change",  this._onCountryChange.bind(this))
    this.provinceEl.addEventListener("change", this._onProvinceChange.bind(this))

    // Si ya hay un país seleccionado, restaurar la cadena completa
    if (this.countryEl.value) {
      this._loadProvinces(this.countryEl.value, this._savedProvinceId)
    }
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  _onCountryChange(e) {
    if (this._loading) return
    this._savedProvinceId = null
    this._savedCityId     = null
    this._loadProvinces(e.target.value, null)
  }

  _onProvinceChange(e) {
    if (this._loading) return
    this._savedCityId = null
    this._loadCities(e.target.value, null)
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  _loadProvinces(countryId, restoreProvinceId) {
    if (!countryId) {
      this._setOptions(this.provinceEl, [], "Seleccione provincia")
      this._setOptions(this.cityEl,     [], "Seleccione ciudad")
      return
    }

    this._loading = true
    fetch(`/locations/provinces/${countryId}`)
      .then(r => r.json())
      .then(data => {
        this._setOptions(this.provinceEl, data, "Seleccione provincia", restoreProvinceId)
        this._setOptions(this.cityEl,     [],   "Seleccione ciudad")

        if (restoreProvinceId) {
          // Verificar que la opción quedó seleccionada antes de cargar ciudades
          const selected = this.provinceEl.value
          if (selected) this._loadCities(selected, this._savedCityId)
        }
      })
      .catch(() => {
        this._setOptions(this.provinceEl, [], "Error al cargar provincias")
      })
      .finally(() => { this._loading = false })
  }

  _loadCities(provinceId, restoreCityId) {
    if (!provinceId) {
      this._setOptions(this.cityEl, [], "Seleccione ciudad")
      return
    }

    fetch(`/locations/cities/${provinceId}`)
      .then(r => r.json())
      .then(data => {
        this._setOptions(this.cityEl, data, "Seleccione ciudad", restoreCityId)
      })
      .catch(() => {
        this._setOptions(this.cityEl, [], "Error al cargar ciudades")
      })
  }

  // ── Helper: reemplaza las opciones en UNA sola asignación ─────────────────
  // Usar innerHTML += en un loop destruye y recrea el DOM en cada iteración,
  // lo que puede disparar eventos "change" espurios y resetear el valor.

  _setOptions(selectEl, items, placeholder, selectedId = null) {
    const options = [`<option value="">${placeholder}</option>`]
    items.forEach(item => {
      const sel = selectedId && String(item.id) === String(selectedId) ? " selected" : ""
      options.push(`<option value="${item.id}"${sel}>${item.name}</option>`)
    })
    selectEl.innerHTML = options.join("")
  }
}
