import { Controller } from "@hotwired/stimulus"

// Maneja los selectores dependientes País → Provincia → Ciudad.
//
// Uso en HTML:
//   <div data-controller="location-select"
//        data-location-select-country-id-value="el_id_del_select_pais"
//        data-location-select-province-id-value="el_id_del_select_provincia"
//        data-location-select-city-id-value="el_id_del_select_ciudad"
//        data-location-select-saved-province-id-value="<%= record.province_id %>"
//        data-location-select-saved-city-id-value="<%= record.city_id %>">

export default class extends Controller {
  static values = {
    countryId:       String,
    provinceId:      String,
    cityId:          String,
    savedProvinceId: String,
    savedCityId:     String
  }

  connect() {
    this.countryEl  = document.getElementById(this.countryIdValue)
    this.provinceEl = document.getElementById(this.provinceIdValue)
    this.cityEl     = document.getElementById(this.cityIdValue)

    if (!this.countryEl || !this.provinceEl || !this.cityEl) return

    // Los IDs guardados vienen de data-values (server-side), no del DOM
    this._savedProvinceId = this.savedProvinceIdValue || null
    this._savedCityId     = this.savedCityIdValue     || null

    this.countryEl.addEventListener("change",  this._onCountryChange.bind(this))
    this.provinceEl.addEventListener("change", this._onProvinceChange.bind(this))

    // Si ya hay un país seleccionado, cargar provincias y restaurar selección
    if (this.countryEl.value) {
      this._loadProvinces(this.countryEl.value, this._savedProvinceId)
    }
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  _onCountryChange(e) {
    this._savedProvinceId = null
    this._savedCityId     = null
    this._loadProvinces(e.target.value, null)
  }

  _onProvinceChange(e) {
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

    fetch(`/locations/provinces/${countryId}`)
      .then(r => r.json())
      .then(data => {
        this._setOptions(this.provinceEl, data, "Seleccione provincia", restoreProvinceId)
        // Solo cargar ciudades si hay una provincia a restaurar
        if (restoreProvinceId && this.provinceEl.value) {
          this._loadCities(this.provinceEl.value, this._savedCityId)
        } else {
          this._setOptions(this.cityEl, [], "Seleccione ciudad")
        }
      })
      .catch(() => {
        this._setOptions(this.provinceEl, [], "Error al cargar provincias")
        this._setOptions(this.cityEl,     [], "Seleccione ciudad")
      })
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

  // ── Helper ────────────────────────────────────────────────────────────────

  _setOptions(selectEl, items, placeholder, selectedId = null) {
    const options = [`<option value="">${placeholder}</option>`]
    items.forEach(item => {
      const sel = selectedId && String(item.id) === String(selectedId) ? " selected" : ""
      options.push(`<option value="${item.id}"${sel}>${item.name}</option>`)
    })
    selectEl.innerHTML = options.join("")
  }
}
