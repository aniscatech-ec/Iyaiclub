import { Controller } from "@hotwired/stimulus"

const ROLE_HINTS = {
  owner: {
    new:      "Se creará un usuario <strong>afiliado</strong> y se le asignará como propietario del stand.",
    existing: "Busca y selecciona un usuario <strong>afiliado</strong> existente para asignarle como propietario.",
  },
  vendor: {
    new:      "Se creará un usuario <strong>vendedor</strong> y se le asignará al stand.",
    existing: "Busca y selecciona un usuario <strong>vendedor</strong> existente para asignarle al stand.",
  },
}

export default class extends Controller {
  static targets = [
    "typeRadio", "sourceRadio",
    "userFormBody",
    "newUserSection", "existingUserSection",
    "newUserField",
    "roleHintText", "existingRoleHintText",
    "rucField",
    "searchInput", "searchResults", "existingUserId", "selectedUserLabel",
  ]
  static values = { searchUrl: String }

  connect() {
    this._debounceTimer = null
    this._render()
  }

  onTypeChange() {
    this._render()
  }

  onSourceChange() {
    this._renderSource()
  }

  onSearch() {
    clearTimeout(this._debounceTimer)
    this._debounceTimer = setTimeout(() => this._fetchUsers(), 300)
  }

  async _fetchUsers() {
    const q    = this.searchInputTarget.value.trim()
    const role = this._type() === "owner" ? "afiliado" : "vendedor"
    const url  = `${this.searchUrlValue}?q=${encodeURIComponent(q)}&role=${role}`

    const res     = await fetch(url, { headers: { Accept: "application/json" } })
    const results = await res.json()

    this.searchResultsTarget.innerHTML = results.map(u =>
      `<button type="button" class="list-group-item list-group-item-action small"
               data-id="${u.id}" data-text="${u.text}"
               data-action="click->stand-user-form#selectUser">
        ${u.text}
       </button>`
    ).join("") || `<div class="list-group-item text-muted small">Sin resultados</div>`
  }

  selectUser(event) {
    const btn = event.currentTarget
    this.existingUserIdTarget.value           = btn.dataset.id
    this.selectedUserLabelTarget.textContent  = `Seleccionado: ${btn.dataset.text}`
    this.searchResultsTarget.innerHTML        = ""
    this.searchInputTarget.value              = btn.dataset.text
  }

  // ── private ──────────────────────────────────────────────────────────────

  _type()   { return this.typeRadioTargets.find(r => r.checked)?.value   || "" }
  _source() { return this.sourceRadioTargets.find(r => r.checked)?.value || "new" }

  _render() {
    const type = this._type()
    const hasType = type !== ""

    // Mostrar u ocultar el bloque completo de usuario
    this.userFormBodyTarget.classList.toggle("d-none", !hasType)

    if (!hasType) {
      this._setNewFieldsRequired(false)
      return
    }

    // Actualizar hints de texto
    const hints = ROLE_HINTS[type] || ROLE_HINTS.owner
    this.roleHintTextTarget.innerHTML         = hints.new
    this.existingRoleHintTextTarget.innerHTML = hints.existing

    // RUC solo aplica para vendedor nuevo
    this.rucFieldTarget.classList.toggle("d-none", type !== "vendor")

    this._renderSource()
  }

  _renderSource() {
    const isNew = this._source() === "new"
    this.newUserSectionTarget.classList.toggle("d-none", !isNew)
    this.existingUserSectionTarget.classList.toggle("d-none", isNew)
    this._setNewFieldsRequired(isNew && this._type() !== "")
  }

  // Añade/quita required en los campos de nuevo usuario para que el browser
  // valide solo cuando la sección está activa.
  _setNewFieldsRequired(required) {
    this.newUserFieldTargets.forEach(el => {
      if (required) {
        el.setAttribute("required", "")
      } else {
        el.removeAttribute("required")
      }
    })
  }
}
