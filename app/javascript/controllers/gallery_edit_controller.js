import { Controller } from "@hotwired/stimulus"

// Conecta este controlador con data-controller="gallery-edit"
export default class extends Controller {
    static targets = ["container"]

    connect() {
        console.log("🎨 Controlador gallery-edit conectado")
        this.containerTarget.addEventListener("change", this.updatePreview.bind(this))
    }

    addImages() {
        const input = document.createElement("input")
        input.type = "file"
        input.accept = "image/*"
        input.multiple = true

        input.addEventListener("change", (e) => {
            const container = this.containerTarget
            const nextIndex = parseInt(container.dataset.nextIndex, 10)
            let i = 0

            for (const file of e.target.files) {
                const index = nextIndex + i
                const div = document.createElement("div")
                div.classList.add("gallery-image", "border", "rounded", "p-3", "mb-3", "position-relative", "text-center")

                // 🖼️ Mini preview
                const img = document.createElement("img")
                img.src = URL.createObjectURL(file)
                img.classList.add("preview-img", "rounded", "mb-2", "d-block", "mx-auto")
                img.style.width = "150px"
                img.style.height = "150px"
                img.style.objectFit = "cover"
                div.appendChild(img)

                // ❌ Botón de eliminar temporal
                const removeBtn = document.createElement("button")
                removeBtn.type = "button"
                removeBtn.textContent = "✕"
                removeBtn.classList.add("btn", "btn-sm", "btn-danger", "position-absolute", "top-0", "end-0", "m-1", "rounded-circle")
                removeBtn.addEventListener("click", () => div.remove())
                div.appendChild(removeBtn)

                // 📂 Input de archivo
                const fileInput = document.createElement("input")
                fileInput.type = "file"
                fileInput.name = `gallery[gallery_images_attributes][${index}][file]`
                fileInput.accept = "image/*"
                const dt = new DataTransfer()
                dt.items.add(file)
                fileInput.files = dt.files
                div.appendChild(fileInput)

                // 🔒 Campo hidden para destroy=false
                const hiddenDestroy = document.createElement("input")
                hiddenDestroy.type = "hidden"
                hiddenDestroy.name = `gallery[gallery_images_attributes][${index}][_destroy]`
                hiddenDestroy.value = "false"
                div.appendChild(hiddenDestroy)

                container.appendChild(div)
                i++
            }

            container.dataset.nextIndex = nextIndex + e.target.files.length
        })

        input.click()
    }

    updatePreview(e) {
        if (e.target.matches('input[type="file"]')) {
            const file = e.target.files[0]
            if (!file) return

            const parentDiv = e.target.closest(".gallery-image")
            let img = parentDiv.querySelector("img")

            if (!img) {
                img = document.createElement("img")
                img.classList.add("preview-img", "rounded", "mb-2", "d-block", "mx-auto")
                img.style.width = "150px"
                img.style.height = "150px"
                img.style.objectFit = "cover"
                parentDiv.prepend(img)
            }

            if (img.dataset.prevUrl) URL.revokeObjectURL(img.dataset.prevUrl)

            const newUrl = URL.createObjectURL(file)
            img.src = newUrl
            img.dataset.prevUrl = newUrl
        }
    }
}
