import { Controller } from "@hotwired/stimulus"

// Gestiona la adición de nuevas galerías con imágenes desde el formulario.
// En lugar de interceptar el submit, inserta inputs reales en el DOM para que
// el form los envíe normalmente via multipart (sin fetch manual).
export default class extends Controller {
  static targets = ["container", "name", "files"]

  connect() {
    this._galleryCount = 0
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
    const model = this.element.dataset.model || this._inferModel()
    const container = this.containerTarget

    // Contenedor visual de la galería
    const wrapper = document.createElement("div")
    wrapper.className = "card mb-3 border-0 shadow-sm"
    wrapper.innerHTML = `
      <div class="card-header d-flex justify-content-between align-items-center py-2" style="background:#f8f9fa;">
        <strong class="small"><i class="fas fa-folder-open me-1 text-muted"></i>${name || "Galería"}</strong>
        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill"
                data-action="click->gallery#removeGallery">
          <i class="fas fa-trash me-1"></i> Quitar
        </button>
      </div>
      <div class="card-body p-2 gallery-previews d-flex flex-wrap gap-2"></div>
    `

    const previewArea = wrapper.querySelector(".gallery-previews")

    // Insertar inputs hidden reales + previews de imágenes
    const galleryPrefix = `${model}[establishment_attributes][galleries_attributes][${key}]`

    // Campo nombre
    const nameHidden = document.createElement("input")
    nameHidden.type = "hidden"
    nameHidden.name = `${galleryPrefix}[name]`
    nameHidden.value = name || "Galería"
    wrapper.appendChild(nameHidden)

    // Añadir cada archivo como input file (solo podemos hacer esto clonando el FileList)
    // Usamos un truco: creamos inputs file ocultos y les asignamos los archivos via DataTransfer
    Array.from(files).forEach((file, idx) => {
      const imagePrefix = `${galleryPrefix}[gallery_images_attributes][${key}_${idx}]`

      // Input file real para que el form lo envíe
      const fileInput = document.createElement("input")
      fileInput.type = "file"
      fileInput.name = `${imagePrefix}[file]`
      fileInput.style.display = "none"
      fileInput.accept = "image/jpeg,image/png,image/webp"

      // Asignar el archivo al input via DataTransfer
      try {
        const dt = new DataTransfer()
        dt.items.add(file)
        fileInput.files = dt.files
      } catch (e) {
        // DataTransfer no disponible (Safari < 14.1) — fallback: no preview
        console.warn("DataTransfer no soportado, imagen no se puede previsualizar", e)
      }

      wrapper.appendChild(fileInput)

      // Preview visual
      const reader = new FileReader()
      reader.onload = (e) => {
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "img-thumbnail rounded"
        img.style.cssText = "width:80px;height:60px;object-fit:cover;"
        img.title = file.name
        previewArea.appendChild(img)
      }
      reader.readAsDataURL(file)
    })

    container.appendChild(wrapper)

    // Limpiar los inputs
    nameInput.value = ""
    filesInput.value = ""
  }

  removeGallery(event) {
    event.preventDefault()
    const card = event.target.closest(".card")
    if (card) card.remove()
  }

  _inferModel() {
    // Intenta deducir el modelo desde el action del form (ej: /hotels/1 → hotel)
    const form = this.element
    const action = form.action || ""
    const match = action.match(/\/(\w+)\/?\d*$/)
    if (match) return match[1].replace(/s$/, "") // "hotels" → "hotel"
    return "establishment"
  }
}
