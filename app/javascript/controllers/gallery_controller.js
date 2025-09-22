import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "name", "files"]

    connect() {
        this.galleries = []
    }

    // Renderizar previews
    renderGalleries() {
        this.containerTarget.innerHTML = ""
        this.galleries.forEach((gallery, gIndex) => {
            const div = document.createElement("div")
            div.classList.add("card", "mb-3")
            div.innerHTML = `
        <div class="card-header d-flex justify-content-between align-items-center">
          <strong>${gallery.name}</strong>
          <button type="button" class="btn btn-sm btn-danger" 
            data-action="click->gallery#deleteGallery" data-index="${gIndex}">
            Eliminar galería
          </button>
        </div>
        <div class="card-body" id="gallery-${gIndex}"></div>
        <div class="card-footer">
          <input type="file" class="form-control mb-2" multiple 
            data-action="change->gallery#addImages" data-index="${gIndex}">
        </div>
      `
            const body = div.querySelector(`#gallery-${gIndex}`)
            gallery.files.forEach((file, fIndex) => {
                const url = URL.createObjectURL(file)
                const imgDiv = document.createElement("div")
                imgDiv.classList.add("d-inline-block", "position-relative", "me-2", "mb-2")
                imgDiv.innerHTML = `
          <img src="${url}" class="img-thumbnail" style="width:120px;height:120px;object-fit:cover;">
          <button type="button" class="btn btn-sm btn-danger position-absolute top-0 end-0"
            data-action="click->gallery#deleteImage"
            data-gindex="${gIndex}" data-findex="${fIndex}">x</button>
        `
                body.appendChild(imgDiv)
            })
            this.containerTarget.appendChild(div)
        })
    }

    // Agregar galería
    addGallery() {
        const name = this.nameTarget.value
        const files = this.filesTarget.files

        if (!name || files.length === 0) {
            alert("Agrega un nombre y al menos una imagen")
            return
        }

        const uniqueKey = Date.now().toString() // 🔑 índice único para Rails
        this.galleries.push({ key: uniqueKey, name, files: Array.from(files) })
        this.renderGalleries()

        this.nameTarget.value = ""
        this.filesTarget.value = ""
    }

    // Eliminar galería
    deleteGallery(event) {
        const index = event.target.dataset.index
        this.galleries.splice(index, 1)
        this.renderGalleries()
    }

    // Eliminar imagen
    deleteImage(event) {
        const gIndex = event.target.dataset.gindex
        const fIndex = event.target.dataset.findex
        this.galleries[gIndex].files.splice(fIndex, 1)
        if (this.galleries[gIndex].files.length === 0) {
            this.galleries.splice(gIndex, 1)
        }
        this.renderGalleries()
    }

    // Añadir imágenes a galería existente
    addImages(event) {
        const gIndex = event.target.dataset.index
        const files = Array.from(event.target.files)
        this.galleries[gIndex].files = this.galleries[gIndex].files.concat(files)
        this.renderGalleries()
    }

    // Interceptar submit
    submitForm(event) {
        event.preventDefault()
        const form = this.element
        const formData = new FormData(form)

        const model = form.dataset.model

        this.galleries.forEach((gallery) => {
            // usamos key único para nuevas galerías
            formData.append(`${model}[establishment_attributes][galleries_attributes][${gallery.key}][name]`, gallery.name)
            gallery.files.forEach((file, fIndex) => {
                formData.append(`${model}[establishment_attributes][galleries_attributes][${gallery.key}][gallery_images_attributes][${fIndex}][file]`, file)
            })
        })

        fetch(form.action, {
            method: form.method,
            body: formData,
            headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content }
        }).then(resp => {
            if (resp.redirected) {
                window.location.href = resp.url
            } else {
                resp.text().then(html => { document.body.innerHTML = html })
            }
        })
    }
}
