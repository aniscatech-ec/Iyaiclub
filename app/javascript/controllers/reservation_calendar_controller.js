import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        hotelId: Number,
        unitId: Number,
        disabledRanges: Array
    }

    connect() {
        const calendarEl = this.element.querySelector("#calendar")
        const messageEl = this.element.querySelector("#selection-message")
        const startInput = document.getElementById("start_date")
        const endInput = document.getElementById("end_date")
        const submitBtn = document.getElementById("submit-btn")

        let startDate = null
        let endDate = null

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: "dayGridMonth",
            locale: "es",
            selectable: true,
            dateClick: (info) => {
                const clickedDate = info.dateStr

                if (this.isDisabled(clickedDate)) {
                    alert("🚫 Esta fecha ya está reservada.")
                    return
                }

                // Seleccionar fecha inicial
                if (!startDate) {
                    startDate = clickedDate
                    this.resetCalendarColors(calendarEl)
                    this.highlightDate(info.dayEl, "#0d6efd")
                    startInput.value = clickedDate
                    endInput.value = ""
                    messageEl.textContent = "📅 Ahora selecciona la fecha de fin de tu estadía (o guarda si es solo un día)."
                    submitBtn.disabled = false // ✅ permitir guardar reservas de 1 día
                    return
                }

                // Seleccionar fecha final
                if (!endDate) {
                    if (new Date(clickedDate) < new Date(startDate)) {
                        alert("⚠️ La fecha de fin debe ser posterior o igual a la de inicio.")
                        return
                    }

                    if (this.isRangeDisabled(startDate, clickedDate)) {
                        alert("🚫 El rango seleccionado se superpone con fechas reservadas.")
                        return
                    }

                    endDate = clickedDate
                    this.highlightRange(calendarEl, startDate, endDate, "#198754")
                    endInput.value = clickedDate
                    messageEl.textContent = "✅ Fechas seleccionadas correctamente."
                    submitBtn.disabled = false
                    return
                }

                // Reiniciar selección si ya había un rango
                this.resetCalendarColors(calendarEl)
                startDate = clickedDate
                endDate = null
                startInput.value = clickedDate
                endInput.value = ""
                this.highlightDate(info.dayEl, "#0d6efd")
                messageEl.textContent = "📅 Ahora selecciona la fecha de fin de tu estadía (o guarda si es solo un día)."
                submitBtn.disabled = false
            }
        })

        calendar.render()

        // Pintar fechas deshabilitadas
        this.disabledRangesValue.forEach(range => {
            const start = new Date(range.start)
            const end = new Date(range.end)
            for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
                const dateStr = d.toISOString().split("T")[0]
                const el = calendarEl.querySelector(`[data-date="${dateStr}"]`)
                if (el) {
                    el.style.backgroundColor = "#ffcccc"
                    el.style.color = "#000"
                }
            }
        })

        // ✅ Ajuste final: si solo se elige una fecha, el end_date se iguala al start_date antes de enviar
        const form = this.element.querySelector("form")
        form.addEventListener("submit", (e) => {
            if (startInput.value && !endInput.value) {
                endInput.value = startInput.value
            }
        })
    }

    highlightDate(dayEl, color) {
        dayEl.style.backgroundColor = color
        dayEl.style.color = "#fff"
    }

    highlightRange(calendarEl, start, end, color) {
        const startDate = new Date(start)
        const endDate = new Date(end)
        for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
            const dateStr = d.toISOString().split("T")[0]
            const el = calendarEl.querySelector(`[data-date="${dateStr}"]`)
            if (el && !this.isDisabled(dateStr)) {
                el.style.backgroundColor = color
                el.style.color = "#fff"
            }
        }
    }

    resetCalendarColors(calendarEl) {
        const days = calendarEl.querySelectorAll("[data-date]")
        days.forEach((el) => {
            if (!this.isDisabled(el.dataset.date)) {
                el.style.backgroundColor = ""
                el.style.color = ""
            }
        })
    }

    isDisabled(dateStr) {
        return this.disabledRangesValue.some(range => {
            return dateStr >= range.start && dateStr <= range.end
        })
    }

    isRangeDisabled(start, end) {
        const startDate = new Date(start)
        const endDate = new Date(end)
        return this.disabledRangesValue.some(range => {
            const reservedStart = new Date(range.start)
            const reservedEnd = new Date(range.end)
            return startDate <= reservedEnd && endDate >= reservedStart
        })
    }
}
