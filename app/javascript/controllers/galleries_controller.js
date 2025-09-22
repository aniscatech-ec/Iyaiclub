import { Controller } from "@hotwired/stimulus"

// Conecta con data-controller="galleries"
export default class extends Controller {
    static targets = ["container", "name", "files", "form"]

    connect() {
        this.galleries = []
    }

    addGallery() {
        const name = this.nameTarget.value
        const files = this.filesTarget.files

        if (!name || files.length === 0) {
            alert("Agrega un nombre y al menos una imagen")
            return
        }

        const gallery = { name, files: Array.from(files) }
        this.galleries.push(gallery)

        // Mostrar preview
        const div = document.createElement("div")
        div.classList.add("mb-3")
        div.innerHTML = `<strong>${name}</strong><br>`
        gallery.files.forEach((file, index) => {
            const url = URL.createObjectURL(file)
            div.innerHTML += `
        <div class="d-inline-block position-relative me-2 mb-2">
          <img src="${url}" class="img-thumbnail" style="width:120px;height:120px;object-fit:cover;">
          <button type="button" class="btn btn-sm btn-danger position-absolute top-0 end-0"
            data-action="click->galleries#removeImage"
            data-gallery-index="${this.galleries.length - 1}"
            data-file-index="${index}">
            X
          </button>
        </div>
      `
        })
        this.containerTarget.appendChild(div)

        // reset
        this.nameTarget.value = ""
        this.filesTarget.value = ""
    }

    removeImage(e) {
        const gIndex = e.target.dataset.galleryIndex
        const fIndex = e.target.dataset.fileIndex

        this.galleries[gIndex].files.splice(fIndex, 1)

        if (this.galleries[gIndex].files.length === 0) {
            this.galleries.splice(gIndex, 1)
        }

        this.renderPreviews()
    }

    renderPreviews() {
        this.containerTarget.innerHTML = ""
        this.galleries.forEach((gallery, gIndex) => {
            const div = document.createElement("div")
            div.classList.add("mb-3")
            div.innerHTML = `<strong>${gallery.name}</strong><br>`
            gallery.files.forEach((file, fIndex) => {
                const url = URL.createObjectURL(file)
                div.innerHTML += `
          <div class="d-inline-block position-relative me-2 mb-2">
            <img src="${url}" class="img-thumbnail" style="width:120px;height:120px;object-fit:cover;">
            <button type="button" class="btn btn-sm btn-danger position-absolute top-0 end-0"
              data-action="click->galleries#removeImage"
              data-gallery-index="${gIndex}"
              data-file-index="${fIndex}">
              X
            </button>
          </div>
        `
            })
            this.containerTarget.appendChild(div)
        })
    }

    submitForm(e) {
        e.preventDefault()

        const formData = new FormData(this.formTarget)

        // Anexar las galerías como nested attributes
        this.galleries.forEach((gallery, gIndex) => {
            formData.append(`restaurant[establishment_attributes][galleries_attributes][${gIndex}][name]`, gallery.name)

            gallery.files.forEach((file, fIndex) => {
                formData.append(
                    `restaurant[establishment_attributes][galleries_attributes][${gIndex}][gallery_images_attributes][${fIndex}][file]`,
                    file
                )
            })
        })

        fetch(this.formTarget.action, {
            method: this.formTarget.method,
            body: formData,
            headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content }
        }).then(resp => {
            if (resp.redirected) {
                window.location.href = resp.url
            } else {
                return resp.text().then(html => {
                    document.body.innerHTML = html
                })
            }
        })
    }
}
