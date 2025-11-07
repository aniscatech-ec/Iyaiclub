import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        hotelId: Number,
        unitId: Number,
        reservations: Array
    }

    connect() {
        const calendarEl = document.getElementById("calendar")
        const reservations = this.reservationsValue || []

        const events = reservations.map(r => ({
            id: r.id,
            title: r.user?.email || "Reserva",
            start: r.start_date,
            end: this.addOneDay(r.end_date), // FullCalendar no incluye el último día
            color: "#198754" // verde
        }))

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: "dayGridMonth",
            locale: "es",
            selectable: false,
            events: events,
            eventClick: (info) => {
                const email = info.event.title
                const start = info.event.start.toISOString().split("T")[0]
                const end = new Date(info.event.end.getTime() - 86400000).toISOString().split("T")[0]
                alert(`Reserva de: ${email}\nDesde: ${start}\nHasta: ${end}`)
            }
        })

        calendar.render()
    }

    addOneDay(dateStr) {
        const date = new Date(dateStr)
        date.setDate(date.getDate() + 1)
        return date.toISOString().split("T")[0]
    }
}
