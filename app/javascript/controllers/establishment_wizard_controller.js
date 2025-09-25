import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hidden"]

    goToChooseType() {
        const userId = this.hiddenTarget.value
        if (!userId) {
            alert("Por favor selecciona un afiliado.")
            return
        }

        // Redirigir al flujo normal
        window.location.href = `/establishments/choose_type?user_id=${userId}`
    }
}
