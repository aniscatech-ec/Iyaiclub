import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("submit", this.validate.bind(this))
    this.createToastContainer()
  }

  disconnect() {
    this.element.removeEventListener("submit", this.validate.bind(this))
    const container = document.getElementById("validation-toast-container")
    if (container) container.remove()
  }

  createToastContainer() {
    if (document.getElementById("validation-toast-container")) return

    const container = document.createElement("div")
    container.id = "validation-toast-container"
    container.className = "toast-container position-fixed top-0 end-0 p-3"
    container.style.zIndex = "1080"
    document.body.appendChild(container)
  }

  validate(event) {
    const missingFields = []
    const requiredInputs = this.element.querySelectorAll("[required]")

    requiredInputs.forEach((input) => {
      const value = input.value ? input.value.trim() : ""
      if (!value) {
        missingFields.push(this.getFieldLabel(input))
        input.classList.add("is-invalid")

        // Quitar el borde rojo cuando el usuario empiece a escribir
        input.addEventListener("input", () => input.classList.remove("is-invalid"), { once: true })
        input.addEventListener("change", () => input.classList.remove("is-invalid"), { once: true })
      } else {
        input.classList.remove("is-invalid")
      }
    })

    if (missingFields.length > 0) {
      event.preventDefault()
      event.stopImmediatePropagation()
      this.showToast(missingFields)

      // Hacer scroll al primer campo con error
      const firstInvalid = this.element.querySelector(".is-invalid")
      if (firstInvalid) {
        firstInvalid.scrollIntoView({ behavior: "smooth", block: "center" })
        firstInvalid.focus()
      }
    }
  }

  getFieldLabel(input) {
    // Buscar label asociado por atributo "for"
    const id = input.id
    if (id) {
      const label = this.element.querySelector(`label[for="${id}"]`)
      if (label) {
        return label.textContent.replace(/\s*\*\s*$/, "").trim()
      }
    }

    // Buscar label padre mas cercano
    const parentGroup = input.closest(".col-md-6, .col-md-4, .col-md-3, .col-md-8, .col-12")
    if (parentGroup) {
      const label = parentGroup.querySelector("label")
      if (label) {
        return label.textContent.replace(/\s*\*\s*$/, "").trim()
      }
    }

    // Fallback: usar el placeholder o el name
    return input.placeholder || input.name || "Campo requerido"
  }

  showToast(missingFields) {
    const container = document.getElementById("validation-toast-container")
    if (!container) return

    // Limpiar toasts anteriores
    container.innerHTML = ""

    const fieldList = missingFields.map((f) => `<li>${f}</li>`).join("")

    const toastEl = document.createElement("div")
    toastEl.className = "toast show validation-toast"
    toastEl.setAttribute("role", "alert")
    toastEl.setAttribute("aria-live", "assertive")
    toastEl.setAttribute("aria-atomic", "true")

    toastEl.innerHTML = `
      <div class="toast-header bg-danger text-white">
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong class="me-auto">Campos obligatorios faltantes</strong>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Cerrar"></button>
      </div>
      <div class="toast-body">
        <p class="mb-2 fw-semibold">Por favor completa los siguientes campos antes de continuar:</p>
        <ul class="mb-0 ps-3">${fieldList}</ul>
      </div>
    `

    container.appendChild(toastEl)

    // Auto-cerrar despues de 8 segundos
    setTimeout(() => {
      toastEl.classList.remove("show")
      setTimeout(() => toastEl.remove(), 300)
    }, 8000)

    // Cerrar al hacer click en el boton X
    const closeBtn = toastEl.querySelector(".btn-close")
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        toastEl.classList.remove("show")
        setTimeout(() => toastEl.remove(), 300)
      })
    }
  }
}
