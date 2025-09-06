import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { events: Array }
    static targets = ["calendar"]

    connect() {
        console.log("✅ FullCalendar Stimulus conectado")
        console.log("🔎 eventsValue:", this.eventsValue)

        if (!window.FullCalendar) {
            console.error("❌ FullCalendar no está disponible todavía")
            return
        }

        if (this.calendar) this.calendar.destroy()

        this.calendar = new window.FullCalendar.Calendar(this.calendarTarget, {
            initialView: "dayGridWeek",
            initialDate: new Date().toISOString().split("T")[0],
            headerToolbar: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,dayGridWeek,dayGridDay"
            },
            selectable: true,
            editable: true,
            events: this.eventsValue || [],
            dateClick: this.dateClick.bind(this)
        })

        this.calendar.render()

        // inicializa el hidden con lo que ya venga (por si hay eventos preexistentes)
        this.updateHiddenField()
    }

    dateClick(info) {
        // alterna disponibilidad al hacer click
        const event = this.calendar.getEventById(info.dateStr)
        if (event) {
            event.remove()
        } else {
            this.calendar.addEvent({
                id: info.dateStr,
                title: "Disponible",
                start: info.dateStr,
                allDay: true
            })
        }

        // IMPORTANT: actualizar el campo oculto cada vez que cambia algo
        this.updateHiddenField()
    }

    getAvailableDates() {
        return this.calendar.getEvents().map(e => e.startStr)
    }

    updateHiddenField() {
        const hiddenInput = document.getElementById("unit_availabilities_json")
        if (!hiddenInput) {
            console.warn("⚠️ hidden input #unit_availabilities_json no encontrado")
            return
        }
        const json = JSON.stringify(this.getAvailableDates())
        hiddenInput.value = json
        console.log("📩 Fechas actualizadas (hidden):", json)
    }

    disconnect() {
        if (this.calendar) {
            this.calendar.destroy()
            this.calendar = null
        }
    }
}
