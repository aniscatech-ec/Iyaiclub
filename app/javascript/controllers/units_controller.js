import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container"]

    connect() {
        console.log("🧩 Controlador Units conectado")
    }

    addUnit() {
        const template = document.getElementById("unit-template")
        const clone = template.content.cloneNode(true)
        const uniqueId = new Date().getTime().toString() // ID único por unidad

        // Reemplazar NEW_RECORD por el uniqueId
        clone.querySelectorAll("*").forEach(el => {
            if (el.hasAttribute("name")) {
                el.setAttribute("name", el.getAttribute("name").replaceAll("NEW_RECORD", uniqueId))
            }
            if (el.hasAttribute("id")) {
                el.setAttribute("id", el.getAttribute("id").replaceAll("NEW_RECORD", uniqueId))
            }

            for (const attr of el.getAttributeNames()) {
                if (attr.startsWith("data-") && el.getAttribute(attr).includes("NEW_RECORD")) {
                    el.setAttribute(attr, el.getAttribute(attr).replaceAll("NEW_RECORD", uniqueId))
                }
            }
        })

        // Actualizar data-unit-id para el controlador de camas
        const bedContainer = clone.querySelector('[data-controller="bed"]')
        if (bedContainer) {
            bedContainer.dataset.bedUnitIdValue = uniqueId
        }

        // Inicializar calendario para la nueva unidad
        const calendarWrapper = clone.querySelector('[data-controller="fullcalendarreg"]')
        if (calendarWrapper) {
            calendarWrapper.dataset.fullcalendarregUnitIndexValue = uniqueId
            calendarWrapper.dataset.fullcalendarregEventsValue = "[]"
            console.log(`📅 Asignado calendario con unitIndex ${uniqueId}`)
        }

        this.containerTarget.appendChild(clone)

        // Reiniciar Stimulus
        requestAnimationFrame(() => {
            if (window.StimulusApplication) {
                window.StimulusApplication.start()
                console.log("🔁 Stimulus reiniciado para nueva unidad")
            }
        })
    }
}
