import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundValidate = this.validate.bind(this)
    this.element.addEventListener("submit", this.boundValidate, true)
    this.createToastContainer()
  }

  disconnect() {
    this.element.removeEventListener("submit", this.boundValidate, true)
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
      if (input.type === "hidden" || input.disabled) return
      // Ignorar inputs dentro de <template> (no visibles)
      if (input.closest("template")) return

      const value = input.value ? input.value.trim() : ""
      let invalid = false
      let errorMsg = null

      if (!value) {
        invalid = true
      } else if (input.type === "email") {
        const emailPattern = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/
        if (!emailPattern.test(value)) {
          invalid = true
          errorMsg = `${this.getFieldLabel(input)} (formato inválido)`
        }
      } else if (input.pattern) {
        const pattern = new RegExp(`^(?:${input.pattern})$`)
        if (!pattern.test(value)) {
          invalid = true
          errorMsg = `${this.getFieldLabel(input)} (formato inválido)`
        }
      }

      if (invalid) {
        missingFields.push(errorMsg || this.getFieldLabel(input))
        input.classList.add("is-invalid")
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

      const firstInvalid = this.element.querySelector(".is-invalid")
      if (firstInvalid) {
        firstInvalid.scrollIntoView({ behavior: "smooth", block: "center" })
        setTimeout(() => firstInvalid.focus({ preventScroll: true }), 300)
      }
    }
  }

  getFieldLabel(input) {
    // 1. Label asociado por atributo "for"
    const id = input.id
    if (id) {
      const label = document.querySelector(`label[for="${CSS.escape(id)}"]`)
      if (label) return this.cleanLabel(label.textContent)
    }

    // 2. Label padre inmediato
    const parentLabel = input.closest("label")
    if (parentLabel) return this.cleanLabel(parentLabel.textContent)

    // 3. Label en el grupo contenedor
    const parentGroup = input.closest(
      ".col, .col-12, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-8, .col-md-12, .mb-3, .mb-2, .form-group"
    )
    if (parentGroup) {
      const label = parentGroup.querySelector("label")
      if (label) return this.cleanLabel(label.textContent)
    }

    // 4. Fallback
    return input.getAttribute("aria-label") || input.placeholder || this.humanizeName(input.name) || "Campo requerido"
  }

  cleanLabel(text) {
    return text.replace(/\s*\*\s*$/, "").replace(/\s+/g, " ").trim()
  }

  humanizeName(name) {
    if (!name) return null
    const match = name.match(/\[([^\[\]]+)\](?!.*\[)/)
    const key = match ? match[1] : name
    return key.replace(/_id$/, "").replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())
  }

  showToast(missingFields) {
    const container = document.getElementById("validation-toast-container")
    if (!container) return

    container.innerHTML = ""

    const uniqueFields = [...new Set(missingFields)]
    const fieldList = uniqueFields.map(f => `<li>${f}</li>`).join("")
    const count = uniqueFields.length

    const toastEl = document.createElement("div")
    toastEl.className = "toast show validation-toast"
    toastEl.setAttribute("role", "alert")
    toastEl.setAttribute("aria-live", "assertive")
    toastEl.setAttribute("aria-atomic", "true")
    toastEl.style.minWidth = "320px"
    toastEl.style.maxWidth = "420px"

    toastEl.innerHTML = `
      <div class="toast-header bg-danger text-white">
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong class="me-auto">${count === 1 ? "Falta 1 campo obligatorio" : `Faltan ${count} campos obligatorios`}</strong>
        <button type="button" class="btn-close btn-close-white" aria-label="Cerrar"></button>
      </div>
      <div class="toast-body">
        <p class="mb-2 fw-semibold small">Completa los siguientes campos antes de continuar:</p>
        <ul class="mb-0 ps-3 small" style="max-height: 240px; overflow-y: auto;">${fieldList}</ul>
      </div>
    `

    container.appendChild(toastEl)

    const autoCloseTimeout = setTimeout(() => {
      toastEl.classList.remove("show")
      setTimeout(() => toastEl.remove(), 300)
    }, 10000)

    const closeBtn = toastEl.querySelector(".btn-close")
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        clearTimeout(autoCloseTimeout)
        toastEl.classList.remove("show")
        setTimeout(() => toastEl.remove(), 300)
      })
    }
  }
}
