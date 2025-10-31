import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { events: Array }

    connect() {
        console.log("✅ fullcalendar_show conectado", this.eventsValue)
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

        const container = this.element.querySelector(".calendar-container") || this.element

        this.calendar = new window.FullCalendar.Calendar(container, {
            initialView: "dayGridMonth",
            headerToolbar: { left: "prev,next today", center: "title", right: "" },
            locale: this.initialLocaleCode,
            events: this.eventsValue || [],
            selectable: false,
            editable: false,
            height: "100%"
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
