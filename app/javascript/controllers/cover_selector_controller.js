import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String, id: Number }

    async setCover() {
        if (!confirm("¿Deseas establecer esta imagen como portada del establecimiento?")) return

        try {
            const response = await fetch(this.urlValue, {
                method: "PATCH",
                headers: {
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
                    "Accept": "application/json"
                }
            })

            if (response.ok) {
                // 🔸 Desmarcar las demás
                document.querySelectorAll(".gallery-image").forEach(div => {
                    div.classList.remove("border-warning")
                    const btn = div.querySelector("button")
                    if (btn) {
                        btn.classList.remove("btn-warning")
                        btn.classList.add("btn-outline-secondary")
                        btn.textContent = "Marcar portada"
                    }
                })

                // 🔸 Marcar la nueva portada
                this.element.classList.add("border-warning")
                const btn = this.element.querySelector("button")
                btn.classList.remove("btn-outline-secondary")
                btn.classList.add("btn-warning")
                btn.textContent = "⭐ Portada"
            } else {
                alert("Error al actualizar la portada")
            }
        } catch (error) {
            console.error(error)
            alert("Error al comunicarse con el servidor")
        }
    }
}
