import { Controller } from "@hotwired/stimulus"

// Versión legacy — no está en uso activo. Mantener sincronizado con gallery_controller.js
// NO intercepta el submit: inserta inputs reales en el DOM para envío multipart normal.
export default class extends Controller {
  static targets = ["container", "name", "files"]

  connect() {
    this._count = 0
  }

  addGallery() {
    const nameInput = this.nameTarget
    const filesInput = this.filesTarget
    const name = nameInput.value.trim()
    const files = filesInput.files

    if (files.length === 0) {
      alert("Selecciona al menos una imagen para la galería")
      return
    }

    const key = Date.now()
    const model = this.element.dataset.model || "restaurant"
    const container = this.containerTarget

    const wrapper = document.createElement("div")
    wrapper.className = "card mb-3 border-0 shadow-sm"
    wrapper.innerHTML = `
      <div class="card-header d-flex justify-content-between align-items-center py-2" style="background:#f8f9fa;">
        <strong class="small"><i class="fas fa-folder-open me-1 text-muted"></i>${name || "Galería"}</strong>
        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill"
                data-action="click->galleries#removeGallery">
          <i class="fas fa-trash me-1"></i> Quitar
        </button>
      </div>
      <div class="card-body p-2 gallery-previews d-flex flex-wrap gap-2"></div>
    `

    const previewArea = wrapper.querySelector(".gallery-previews")
    const galleryPrefix = `${model}[establishment_attributes][galleries_attributes][${key}]`

    const nameHidden = document.createElement("input")
    nameHidden.type = "hidden"
    nameHidden.name = `${galleryPrefix}[name]`
    nameHidden.value = name || "Galería"
    wrapper.appendChild(nameHidden)

    Array.from(files).forEach((file, idx) => {
      const imagePrefix = `${galleryPrefix}[gallery_images_attributes][${key}_${idx}]`
      const fileInput = document.createElement("input")
      fileInput.type = "file"
      fileInput.name = `${imagePrefix}[file]`
      fileInput.style.display = "none"
      fileInput.accept = "image/jpeg,image/png,image/webp"

      try {
        const dt = new DataTransfer()
        dt.items.add(file)
        fileInput.files = dt.files
      } catch (e) {
        console.warn("DataTransfer no soportado", e)
      }

      wrapper.appendChild(fileInput)

      const reader = new FileReader()
      reader.onload = (e) => {
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "img-thumbnail rounded"
        img.style.cssText = "width:80px;height:60px;object-fit:cover;"
        previewArea.appendChild(img)
      }
      reader.readAsDataURL(file)
    })

    container.appendChild(wrapper)
    nameInput.value = ""
    filesInput.value = ""
  }

  removeGallery(event) {
    event.preventDefault()
    const card = event.target.closest(".card")
    if (card) card.remove()
  }
}
