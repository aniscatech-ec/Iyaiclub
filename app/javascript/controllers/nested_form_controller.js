import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "target"]

  add(e) {
    e.preventDefault()
    let content = this.templateTarget.innerHTML
    let newId = new Date().getTime()
    content = content.replace(/NEW_RECORD/g, newId)
    this.targetTarget.insertAdjacentHTML('beforeend', content)
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
  }
}
