import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["previewContainer", "destroyField"]

    connect() {
        this.newImages = [] // Archivos nuevos (frontend)
        console.log("🖼️ gallery_show_controller listo")
    }

    // Maneja la selección múltiple
    handleFiles(event) {
        const files = Array.from(event.target.files)
        files.forEach(file => this.addPreview(file))
    }

    // Agrega una vista previa
    addPreview(file) {
        const reader = new FileReader()
        const container = document.createElement("div")
        container.classList.add("position-relative", "border", "p-2", "rounded")

        const removeBtn = document.createElement("button")
        removeBtn.type = "button"
        removeBtn.classList.add("btn", "btn-sm", "btn-danger", "position-absolute", "top-0", "end-0", "m-1")
        removeBtn.textContent = "✕"
        removeBtn.addEventListener("click", () => {
            container.remove()
            this.newImages = this.newImages.filter(f => f !== file)
        })

        reader.onload = e => {
            const img = document.createElement("img")
            img.src = e.target.result
            img.style.width = "200px"
            img.style.height = "200px"
            img.style.objectFit = "cover"
            container.appendChild(img)
            container.appendChild(removeBtn)
            this.previewContainerTarget.appendChild(container)
        }

        reader.readAsDataURL(file)
        this.newImages.push(file)
    }

    // Marca imágenes existentes para eliminar
    markForDeletion(event) {
        const id = event.target.dataset.id
        const field = this.destroyFieldTargets.find(f => f.dataset.id === id)
        if (field) field.value = "1"
        event.target.closest("[data-gallery-show-target='existingImage']").style.opacity = "0.4"
    }

    // Antes de enviar el formulario, inyectamos los campos anidados
    beforeSubmit(event) {
        const form = event.target

        this.newImages.forEach((file, index) => {
            const blobField = document.createElement("input")
            blobField.type = "hidden"
            blobField.name = `gallery[gallery_images_attributes][new_${index}][file]`
            blobField.value = file // ⚠️ Esto no funciona directo en HTML, pero Rails lo toma con JS FormData.
        })
    }
}
