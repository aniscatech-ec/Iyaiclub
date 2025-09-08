import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
    static values = { events: Array }

    connect() {
        console.log("✅ FullCalendar Stimulus conectado")
        var initialLocaleCode = 'es';

        if (!window.FullCalendar) {
            console.error("❌ FullCalendar no está disponible todavía")
            return
        }

        if (this.calendar) this.calendar.destroy()

        this.calendar = new window.FullCalendar.Calendar(this.element, {
            initialView: "dayGridMonth",
            initialDate: new Date().toISOString().split("T")[0],
            headerToolbar: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,dayGridWeek,dayGridDay"
            },
            selectable: true,
            editable: true,
            locale: initialLocaleCode,
            events: this.eventsValue || [],
            dateClick: this.dateClick.bind(this)
        })


        this.calendar.render()
    }

    dateClick(info) {
        const existing = this.calendar.getEventById(info.dateStr)

        if (!existing) {
            // estado 1 → disponible
            this.calendar.addEvent({
                id: info.dateStr,
                title: "Disponible",
                start: info.dateStr,
                allDay: true,
                color: "green"
            })
        } else if (existing.title === "Disponible") {
            // estado 2 → no disponible
            existing.remove()
            this.calendar.addEvent({
                id: info.dateStr,
                title: "No disponible",
                start: info.dateStr,
                allDay: true,
                color: "red"
            })
        } else {
            // estado 3 → eliminar evento (vacío)
            existing.remove()
        }

        this.updateHiddenField()
    }

    updateHiddenField() {
        const hiddenInput = document.getElementById("unit_availabilities_json")
        hiddenInput.value = JSON.stringify(this.getAvailableDates())
        console.log("📩 Fechas actualizadas:", hiddenInput.value)
    }

    getAvailableDates() {
        return this.calendar.getEvents().map(e => ({
            date: e.startStr,
            available: e.title === "Disponible"
        }))
    }

    disconnect() {
        if (this.calendar) {
            this.calendar.destroy()
            this.calendar = null
        }
    }
}
