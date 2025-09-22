import { Controller } from "@hotwired/stimulus"

// Conectar: data-controller="gallery-image"
export default class extends Controller {
    static targets = ["counter", "wrapper"]

    connect() {
        console.log("GalleryImage controller conectado ✅")

        // Asignar evento a todos los botones de eliminar
        this.element.querySelectorAll(".remove-image").forEach(btn => {
            btn.addEventListener("click", this.removeImage.bind(this))
        })
    }

    removeImage(e) {
        const button = e.target
        const parentDiv = button.closest("[data-image-id]")
        const galleryId = parentDiv.dataset.galleryId
        const imageId = parentDiv.dataset.imageId

        if (confirm("¿Seguro que deseas eliminar esta imagen?")) {
            fetch(`/hotels/${this.element.dataset.hotelId}/remove_image`, {
                method: "DELETE",
                headers: {
                    "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    remove_gallery_image_id: imageId,
                    gallery_id: galleryId
                })
            }).then(resp => {
                if (resp.ok) {
                    // Eliminar imagen del DOM
                    parentDiv.remove()

                    // Actualizar contador
                    const counter = this.element.querySelector(`.image-counter[data-gallery-id="${galleryId}"]`)
                    const galleryWrapper = this.element.querySelector(`[data-gallery-wrapper="${galleryId}"]`)
                    const remainingImages = galleryWrapper.querySelectorAll("[data-image-id]").length

                    if (remainingImages > 0) {
                        counter.textContent = `(${remainingImages} imágenes)`
                    } else {
                        galleryWrapper.remove()
                    }
                } else {
                    alert("Error al eliminar la imagen")
                }
            })
        }
    }
}
