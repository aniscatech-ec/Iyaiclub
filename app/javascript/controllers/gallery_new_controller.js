import { Controller } from "@hotwired/stimulus"

// Controlador Stimulus para previsualizar y gestionar imágenes antes de crear la galería
export default class extends Controller {
    static targets = ["previewContainer"]

    preview(event) {
        const files = event.target.files
        this.previewContainerTarget.innerHTML = ""

        Array.from(files).forEach((file, index) => {
            const reader = new FileReader()

            reader.onload = (e) => {
                const div = document.createElement("div")
                div.classList.add("position-relative", "m-2")

                div.innerHTML = `
          <img src="${e.target.result}" class="rounded shadow" style="width: 150px; height: 150px; object-fit: cover;">
          <button type="button" class="btn btn-sm btn-danger position-absolute top-0 end-0" data-index="${index}" data-action="click->gallery-new#removeImage">×</button>
        `
                this.previewContainerTarget.appendChild(div)
            }

            reader.readAsDataURL(file)
        })
    }

    removeImage(event) {
        const index = event.target.dataset.index
        const input = this.element.querySelector('input[type="file"]')

        // Crea una nueva lista de archivos sin el eliminado
        const dt = new DataTransfer()
        Array.from(input.files).forEach((file, i) => {
            if (i != index) dt.items.add(file)
        })
        input.files = dt.files

        // Remueve la vista previa
        event.target.parentElement.remove()
    }
}
