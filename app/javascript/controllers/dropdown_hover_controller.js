import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleOutsideClick = this.closeOnOutsideClick.bind(this)
  }

  toggle(event) {
    const isTouchDevice =
      "ontouchstart" in window || navigator.maxTouchPoints > 0

    // En desktop dejamos que CSS hover haga su trabajo
    if (!isTouchDevice) return

    const wrapper = this.element.closest(".category-card-wrapper")
    if (!wrapper) return

    const isOpen = wrapper.classList.contains("is-open")

    // Cerrar todos antes de abrir uno nuevo
    document.querySelectorAll(".category-card-wrapper.is-open").forEach(el => {
      el.classList.remove("is-open")
    })

    if (!isOpen) {
      event.preventDefault()
      wrapper.classList.add("is-open")
      document.addEventListener("click", this.handleOutsideClick)
    } else {
      wrapper.classList.remove("is-open")
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }

  closeOnOutsideClick(event) {
    const openWrappers = document.querySelectorAll(".category-card-wrapper.is-open")

    openWrappers.forEach(wrapper => {
      if (!wrapper.contains(event.target)) {
        wrapper.classList.remove("is-open")
      }
    })

    // Si ya no hay ninguno abierto, quitamos el listener
    if (!document.querySelector(".category-card-wrapper.is-open")) {
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }
}