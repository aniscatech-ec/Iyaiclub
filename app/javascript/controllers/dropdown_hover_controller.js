import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleOutsideClick = this.closeOnOutsideClick.bind(this)
  }

  toggle(event) {
    // Only intercept on touch devices (no hover support)
    if (window.matchMedia("(hover: hover)").matches) return

    const wrapper = this.element.closest(".category-card-wrapper")
    if (!wrapper) return

    if (!wrapper.classList.contains("is-open")) {
      event.preventDefault()
      wrapper.classList.add("is-open")
      document.addEventListener("click", this.handleOutsideClick)
    }
  }

  closeOnOutsideClick(event) {
    const wrapper = this.element.closest(".category-card-wrapper")
    if (wrapper && !wrapper.contains(event.target)) {
      wrapper.classList.remove("is-open")
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }
}
