import { Controller } from "@hotwired/stimulus"

// Conecta este controlador con: data-controller="unit-availability"
export default class extends Controller {
    static values = { hotelId: Number, unitId: Number }

    connect() {
        console.log("🎯 Controlador UnitAvailability conectado")

        const calendarEl = document.getElementById("calendar")
        const csrfToken = document.querySelector('meta[name="csrf-token"]').content

        const eventsUrl = `/hotels/${this.hotelIdValue}/units/${this.unitIdValue}/unit_availabilities.json`
        const postUrl = `/hotels/${this.hotelIdValue}/units/${this.unitIdValue}/unit_availabilities`

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: "dayGridMonth",
            locale: "es",
            selectable: true,
            events: eventsUrl,

            // Al hacer clic en una fecha, alterna disponibilidad
            dateClick(info) {
                const date = info.dateStr

                fetch(postUrl, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "X-CSRF-Token": csrfToken,
                        "Accept": "application/json"
                    },
                    body: JSON.stringify({
                        unit_availability: { date: date }
                    })
                })
                    .then(response => {
                        if (response.ok) {
                            calendar.refetchEvents()
                        } else {
                            console.error("❌ Error al actualizar disponibilidad")
                        }
                    })
                    .catch(err => console.error("Error:", err))
            },

            eventDidMount(info) {
                // const available = info.event.extendedProps.available
                // info.el.style.backgroundColor = available ? "#28a745" : "#dc3545"
                info.el.style.color = "#fff"
            }
        })

        calendar.render()
    }
}
