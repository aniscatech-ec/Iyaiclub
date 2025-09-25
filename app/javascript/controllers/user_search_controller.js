import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "results", "hidden"]

    connect() {
        this.timeout = null

        // Inicializar con valores por defecto
        const defaultName = this.data.get("defaultName")
        const defaultId   = this.data.get("defaultId")

        if (defaultName && defaultId) {
            this.inputTarget.value = defaultName
            this.hiddenTarget.value = defaultId
        }

        // Cerrar dropdown al click fuera
        document.addEventListener("click", this.closeDropdown.bind(this))
    }

    disconnect() {
        document.removeEventListener("click", this.closeDropdown.bind(this))
    }

    search(event) {
        event.stopPropagation()
        clearTimeout(this.timeout)

        this.timeout = setTimeout(() => {
            const query = this.inputTarget.value.trim()
            if (query.length === 0) {
                this.resultsTarget.innerHTML = ""
                return
            }

            fetch(`/admin/users.json?q=${encodeURIComponent(query)}`)
                .then(response => response.json())
                .then(data => {
                    this.resultsTarget.innerHTML = ""
                    if (data.length === 0) {
                        this.resultsTarget.innerHTML = `<div class="dropdown-item text-muted">No se encontraron usuarios</div>`
                        return
                    }

                    data.forEach(user => {
                        const div = document.createElement("div")
                        div.textContent = `${user.name} (${user.email})`
                        div.dataset.userId = user.id
                        div.classList.add("dropdown-item", "cursor-pointer", "px-2", "py-1")
                        div.addEventListener("click", (e) => {
                            e.stopPropagation()
                            this.selectUser(user)
                        })
                        this.resultsTarget.appendChild(div)
                    })
                })
        }, 300)
    }

    selectUser(user) {
        this.hiddenTarget.value = user.id
        this.inputTarget.value = user.name
        this.resultsTarget.innerHTML = ""
    }

    closeDropdown(event) {
        if (!this.element.contains(event.target)) {
            this.resultsTarget.innerHTML = ""
        }
    }
}
