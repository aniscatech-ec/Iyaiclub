import { Controller } from "@hotwired/stimulus"

// Controlador Stimulus: fullcalendarreg
export default class extends Controller {
    static targets = ["calendar", "availabilitiesContainer"]
    static values = { events: Array, unitIndex: Number }

    connect() {
        console.log("✅ FullCalendar conectado para unidad", this.unitIndexValue)
        this.initialLocaleCode = "es"
        this.waitForFullCalendar(() => this.initializeCalendar())
    }

    waitForFullCalendar(callback) {
        if (window.FullCalendar) {
            callback()
        } else {
            setTimeout(() => this.waitForFullCalendar(callback), 50)
        }
    }

    initializeCalendar() {
        if (this.calendar) this.calendar.destroy()

        this.calendar = new window.FullCalendar.Calendar(this.calendarTarget, {
            initialView: "dayGridMonth",
            initialDate: new Date().toISOString().split("T")[0],
            headerToolbar: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,dayGridWeek,dayGridDay"
            },
            selectable: true,
            locale: this.initialLocaleCode,
            events: this.eventsValue || [],
            dateClick: this.dateClick.bind(this)
        })

        this.calendar.render()

        // 🔄 Cargar los hidden fields de las disponibilidades iniciales
        this.loadInitialAvailabilities()
    }

    dateClick(info) {
        const existing = this.calendar.getEventById(info.dateStr)

        if (!existing) {
            // Crear disponibilidad
            this.calendar.addEvent({
                id: info.dateStr,
                title: "Disponible",
                start: info.dateStr,
                allDay: true,
                color: "green"
            })
            this.addHiddenAvailability(info.dateStr, true)
        } else if (existing.title === "Disponible") {
            // Cambiar a no disponible
            existing.remove()
            this.calendar.addEvent({
                id: info.dateStr,
                title: "No disponible",
                start: info.dateStr,
                allDay: true,
                color: "red"
            })
            this.addHiddenAvailability(info.dateStr, false)
        } else {
            // Quitar disponibilidad
            existing.remove()
            this.removeHiddenAvailability(info.dateStr)
        }
    }

    addHiddenAvailability(date, available) {
        // Eliminar si ya existía un campo para esa fecha
        this.removeHiddenAvailability(date)

        const container = this.availabilitiesContainerTarget
        const timestamp = new Date().getTime()

        const dateField = document.createElement("input")
        dateField.type = "hidden"
        dateField.name = `hotel[units_attributes][${this.unitIndexValue}][unit_availabilities_attributes][${timestamp}][date]`
        dateField.value = date

        const availableField = document.createElement("input")
        availableField.type = "hidden"
        availableField.name = `hotel[units_attributes][${this.unitIndexValue}][unit_availabilities_attributes][${timestamp}][available]`
        availableField.value = available

        container.appendChild(dateField)
        container.appendChild(availableField)

        console.log("📅 Añadido availability:", { date, available })
    }

    removeHiddenAvailability(date) {
        const container = this.availabilitiesContainerTarget
        const inputs = container.querySelectorAll("input")

        inputs.forEach(input => {
            if (input.name.includes("[date]") && input.value === date) {
                const match = input.name.match(/\[(\d+)\]\[date\]/)
                if (match) {
                    const index = match[1]
                    container
                        .querySelectorAll(`input[name*="[${index}]"]`)
                        .forEach(el => el.remove())
                }
            }
        })
    }

    loadInitialAvailabilities() {
        // Si ya hay eventos cargados (desde el backend), los sincroniza en hidden fields
        (this.eventsValue || []).forEach(ev => {
            this.addHiddenAvailability(ev.start, ev.title === "Disponible")
        })
    }

    disconnect() {
        if (this.calendar) {
            this.calendar.destroy()
            this.calendar = null
        }
    }
}
