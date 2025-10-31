import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["calendar"]
    static values = { events: Array }

    connect() {
        console.log("✅ fullcalendar_edit_controller conectado")

        // Inicializa el calendario cuando FullCalendar esté disponible
        this.waitForFullCalendar(() => {
            this.initializeCalendar()
        })
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

        // Parsear eventos desde el atributo data-events-value
        let events = []
        try {
            events = this.eventsValue || []
        } catch (e) {
            console.warn("⚠️ Error parseando eventos:", e)
        }

        this.calendar = new window.FullCalendar.Calendar(this.calendarTarget, {
            initialView: "dayGridMonth",
            selectable: true,
            editable: true,
            locale: "es",
            height: "auto",
            headerToolbar: {
                left: "prev,next today",
                center: "title",
                right: "dayGridMonth,dayGridWeek"
            },
            events: events,
            dateClick: this.toggleDate.bind(this)
        })

        this.calendar.render()
    }

    toggleDate(info) {
        const date = info.dateStr
        const existing = this.calendar.getEvents().find(e => e.startStr === date)

        if (existing) {
            // Alternar estado
            if (existing.title === "Disponible") {
                existing.remove()
                this.calendar.addEvent({
                    id: date,
                    title: "No disponible",
                    start: date,
                    allDay: true,
                    color: "red"
                })
            } else {
                existing.remove()
            }
        } else {
            this.calendar.addEvent({
                id: date,
                title: "Disponible",
                start: date,
                allDay: true,
                color: "green"
            })
        }

        this.updateHiddenField()
    }

    updateHiddenField() {
        const events = this.calendar.getEvents().map(e => ({
            date: e.startStr,
            available: e.title === "Disponible"
        }))

        const hiddenInput = this.element.querySelector("[name='unit[availabilities_json]']")
        if (hiddenInput) {
            hiddenInput.value = JSON.stringify(events)
            console.log("📩 Fechas actualizadas:", hiddenInput.value)
        }
    }

    disconnect() {
        if (this.calendar) this.calendar.destroy()
    }
}
