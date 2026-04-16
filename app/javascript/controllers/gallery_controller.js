import { Controller } from "@hotwired/stimulus"

// Gestiona la adición de nuevas galerías con imágenes.
//
// Estrategia: al hacer "Agregar", clona el input[type=file][multiple] original
// (que tiene los File objects reales del SO) y lo inserta en el DOM con el
// name correcto para nested_attributes. El submit multipart normal lo envía.
// No se usa DataTransfer (no funciona en iOS Safari) ni fetch manual.
//
// En el servidor, gallery_images_attributes recibe un input multiple → el
// controller procesa cada archivo creando un GalleryImage por cada uno.
export default class extends Controller {
  static targets = ["container", "name", "files"]

  connect() {
    this._seq = 0
  }

  addGallery(event) {
    event.preventDefault()

    const nameInput = this.nameTarget
    const filesInput = this.filesTarget

    if (!filesInput.files || filesInput.files.length === 0) {
      alert("Selecciona al menos una imagen para la galería")
      return
    }

    const key = Date.now() + (this._seq++)
    const model = this.element.dataset.model || this._inferModel()
    // Usamos un campo especial "files[]" que el controller procesa manualmente
    const filesFieldName = `new_gallery_uploads[${key}][files][]`
    const galleryNameFieldName = `new_gallery_uploads[${key}][name]`

    // Tarjeta visual
    const card = document.createElement("div")
    card.className = "card mb-3 border-0 shadow-sm"
    card.innerHTML = `
      <div class="card-header d-flex justify-content-between align-items-center py-2" style="background:#f8f9fa;">
        <strong class="small">
          <i class="fas fa-folder-open me-1 text-muted"></i>${this._escape(nameInput.value.trim() || "Galería")}
        </strong>
        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill"
                data-action="click->gallery#removeGallery">
          <i class="fas fa-trash me-1"></i> Quitar
        </button>
      </div>
      <div class="card-body p-2 gallery-previews d-flex flex-wrap gap-2"></div>
    `

    // Hidden con el nombre de la galería
    const nameHidden = document.createElement("input")
    nameHidden.type = "hidden"
    nameHidden.name = galleryNameFieldName
    nameHidden.value = nameInput.value.trim() || "Galería"
    card.appendChild(nameHidden)

    // Clonar el input[type=file] original — contiene los File objects reales
    // El clon se inserta en el card con el name correcto y display:none
    const cloned = filesInput.cloneNode(true)
    cloned.name = filesFieldName
    cloned.style.display = "none"
    cloned.removeAttribute("data-gallery-target")
    cloned.removeAttribute("id")
    card.appendChild(cloned)

    // Previews
    const previewArea = card.querySelector(".gallery-previews")
    Array.from(filesInput.files).forEach(file => {
      const reader = new FileReader()
      reader.onload = e => {
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "img-thumbnail rounded"
        img.style.cssText = "width:72px;height:54px;object-fit:cover;"
        img.title = file.name
        previewArea.appendChild(img)
      }
      reader.readAsDataURL(file)
    })

    this.containerTarget.appendChild(card)

    // Limpiar
    nameInput.value = ""
    filesInput.value = ""
  }

  removeGallery(event) {
    event.preventDefault()
    event.target.closest(".card")?.remove()
  }

  _escape(str) {
    return str.replace(/[&<>"']/g, c =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])
    )
  }

  _inferModel() {
    const match = (this.element.action || "").match(/\/(\w+)\/?\d*$/)
    return match ? match[1].replace(/s$/, "") : "establishment"
  }
}
