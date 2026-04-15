import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "target"]

  connect() {
    this.updateEmptyMessage()
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
    const wrapper = e.target.closest('.nested-fields')
    
    // Si es un registro existente (ya guardado), solo lo ocultamos y marcamos _destroy
    const destroyInput = wrapper.querySelector("input[name*='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = '1'
      wrapper.style.display = 'none'
    } else {
      // Si es un registro nuevo (aún no guardado), o el destroy input está hardcoded,
      // intentamos buscar el _destroy, si no lo encontramos lo removemos de DOM.
      wrapper.remove()
    }
    
    this.updateEmptyMessage()
  }

  updateEmptyMessage() {
    // Buscar el mensaje de "no hay habitaciones"
    const emptyMessage = this.element.querySelector('.empty-rooms-message')
    if (emptyMessage) {
      // Contar habitaciones visibles (no marcadas para destruir y no ocultas)
      const visibleRooms = this.targetTarget.querySelectorAll('.nested-fields:not([style*="display: none"])')
      
      if (visibleRooms.length > 0) {
        emptyMessage.style.display = 'none'
      } else {
        emptyMessage.style.display = 'block'
      }
    }
  }
}
