import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "target"]

  connect() {
    this.updateEmptyMessage()
    this._onCollapseHide = this._onCollapse.bind(this, false)
    this._onCollapseShow = this._onCollapse.bind(this, true)
    this.element.addEventListener("hide.bs.collapse", this._onCollapseHide)
    this.element.addEventListener("show.bs.collapse", this._onCollapseShow)
    // Actualizar título en header cuando el usuario escribe el nombre
    this.element.addEventListener("input", this._onInput.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("hide.bs.collapse", this._onCollapseHide)
    this.element.removeEventListener("show.bs.collapse", this._onCollapseShow)
    this.element.removeEventListener("input", this._onInput.bind(this))
  }

  add(e) {
    e.preventDefault()
    let content = this.templateTarget.innerHTML
    let newId = new Date().getTime()
    // Reemplaza cualquier placeholder (NEW_RECORD, NEW_BED, etc.)
    content = content.replace(/NEW_RECORD|NEW_BED/g, newId)
    this.targetTarget.insertAdjacentHTML('beforeend', content)
    this.updateEmptyMessage()
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.currentTarget.closest('.nested-fields')
    if (!wrapper) return

    // Si es un registro existente (ya guardado), solo lo ocultamos y marcamos _destroy
    const destroyInput = wrapper.querySelector("input[name*='[_destroy]']")
    if (destroyInput && destroyInput.value !== '1') {
      destroyInput.value = '1'
      wrapper.style.display = 'none'
    } else if (!destroyInput) {
      wrapper.remove()
    }

    this.updateEmptyMessage()
  }

  updateEmptyMessage() {
    const emptyMessage = this.element.querySelector('.empty-rooms-message')
    if (emptyMessage) {
      const visibleRooms = this.targetTarget.querySelectorAll('.nested-fields:not([style*="display: none"])')
      emptyMessage.style.display = visibleRooms.length > 0 ? 'none' : 'block'
    }
  }

  _onInput(event) {
    // Actualizar el span.nested-item-title con el primer input de texto del item
    const input = event.target
    if (!input.matches('input[type="text"], input:not([type])')) return
    const wrapper = input.closest('.nested-fields')
    if (!wrapper) return
    // Solo si es el primer input de texto (campo "nombre")
    const firstText = wrapper.querySelector('input[type="text"], input:not([type])')
    if (firstText !== input) return
    const titleEl = wrapper.querySelector('.nested-item-title')
    if (titleEl) titleEl.textContent = input.value.trim() || titleEl.dataset.default || 'Sin nombre'
  }

  _onCollapse(expanding, event) {
    // Actualizar ícono chevron del botón toggle de este collapse
    const collapseEl = event.target
    const wrapper = collapseEl.closest('.nested-fields')
    if (!wrapper) return
    const toggle = wrapper.querySelector('.nested-collapse-toggle i')
    if (toggle) {
      toggle.className = expanding ? 'fas fa-chevron-up' : 'fas fa-chevron-down'
    }
    // También actualizar el título del header cuando se colapsa
    const titleSpan = wrapper.querySelector('.nested-item-title')
    if (titleSpan && !expanding) {
      // El título ya está visible en el header, no necesita resumen extra
    }
  }
}
