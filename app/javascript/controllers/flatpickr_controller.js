import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Connects to data-controller="flatpickr"
export default class extends Controller {
    static targets = ["calendar"]

    connect() {
        if (this.hasCalendarTarget) {
            const input = this.calendarTarget

            // obtenemos los arrays desde los data-attributes
            const availableDates = JSON.parse(input.dataset.enabled || "[]")
            const unavailableDates = JSON.parse(input.dataset.disabled || "[]")

            flatpickr(input, {
                inline: true,
                dateFormat: "d/m/Y",
                defaultDate: JSON.parse(input.dataset.dates || "[]"),
                // no usamos disable porque queremos mostrar ambos estados
                onDayCreate: function(dObj, dStr, fp, dayElem) {
                    const date = dayElem.dateObj.toISOString().split("T")[0] // YYYY-MM-DD

                    if (availableDates.includes(date)) {
                        dayElem.classList.add("available-day")
                    }

                    if (unavailableDates.includes(date)) {
                        dayElem.classList.add("unavailable-day")
                    }
                }
            })
        }
    }
}
