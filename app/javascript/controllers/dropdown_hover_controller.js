import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleOutsideClick = this.closeOnOutsideClick.bind(this)

    // 🔥 Bind correcto
    this.boundOpen = this.open.bind(this)
    this.boundClose = this.close.bind(this)

    this.element.addEventListener("mouseenter", this.boundOpen)
    this.element.addEventListener("mouseleave", this.boundClose)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    this.element.removeEventListener("mouseenter", this.boundOpen)
    this.element.removeEventListener("mouseleave", this.boundClose)
  }

  toggle(event) {
    const wrapper = this.element
    const isOpen = wrapper.classList.contains("is-open")

    document.querySelectorAll(".category-card-wrapper.is-open").forEach(el => {
      el.classList.remove("is-open")
    })

    if (!isOpen) {
      event.preventDefault()
      wrapper.classList.add("is-open")
      document.addEventListener("click", this.handleOutsideClick)
    }
  }

  open() {
    // Solo desktop
    if ("ontouchstart" in window || navigator.maxTouchPoints > 0) return

    document.querySelectorAll(".category-card-wrapper.is-open").forEach(el => {
      el.classList.remove("is-open")
      console.log("hover funcionando")
    })

    this.element.classList.add("is-open")
  }

  close() {
    if ("ontouchstart" in window || navigator.maxTouchPoints > 0) return

    this.element.classList.remove("is-open")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.element.classList.remove("is-open")
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }

  // Cierre explícito desde el botón X del bottom sheet (móvil)
  closeSheet(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("is-open")
    document.removeEventListener("click", this.handleOutsideClick)
  }
}