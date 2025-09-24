import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["previewContainer", "input"]

    preview() {
        const file = this.inputTarget.files[0]
        if (!file) return

        const container = this.previewContainerTarget
        container.innerHTML = "" // limpiar preview anterior

        const label = document.createElement("strong")
        label.textContent = "Nuevo ícono:"
        container.appendChild(label)
        container.appendChild(document.createElement("br"))

        const img = document.createElement("img")
        img.src = URL.createObjectURL(file)
        img.style.maxWidth = "32px"
        img.style.maxHeight = "32px"
        img.onload = () => URL.revokeObjectURL(img.src) // liberar memoria

        container.appendChild(img)
        container.classList.add("selected")
    }
}
