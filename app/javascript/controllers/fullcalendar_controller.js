import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static values = {events: Array}

    connect() {
        console.log("✅ FullCalendar Stimulus conectado")

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
            locale: "es",   // 👈 Traducción a español,
            events: this.eventsValue || []
        })

        this.calendar.render()
    }

    disconnect() {
        if (this.calendar) {
            this.calendar.destroy()
            this.calendar = null
        }
    }
}
