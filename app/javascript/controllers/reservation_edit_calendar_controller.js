import { Controller } from "@hotwired/stimulus"

// Controlador para la edición de reservas
export default class extends Controller {
    static values = {
        hotelId: Number,
        unitId: Number,
        disabledRanges: Array,
        initialStart: String,
        initialEnd: String
    }

    connect() {
        const calendarEl = this.element.querySelector("#calendar")
        const messageEl = this.element.querySelector("#selection-message")
        const startInput = document.getElementById("edit_start_date")
        const endInput = document.getElementById("edit_end_date")
        const submitBtn = document.getElementById("edit-submit-btn")

        let startDate = this.initialStartValue
        let endDate = this.initialEndValue

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

                // Selección de fecha de inicio
                if (!startDate) {
                    startDate = clickedDate
                    this.resetCalendarColors(calendarEl)
                    this.highlightDate(info.dayEl, "#0d6efd") // Azul
                    startInput.value = clickedDate
                    endInput.value = ""
                    messageEl.textContent = "📅 Ahora selecciona la nueva fecha de fin (o guarda si es solo un día)."
                    submitBtn.disabled = false // ✅ permitir reservas de 1 día
                    return
                }

                // Selección de fecha de fin
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
                    this.highlightRange(calendarEl, startDate, endDate, "#198754") // Verde
                    endInput.value = clickedDate
                    messageEl.textContent = "✅ Fechas seleccionadas correctamente."
                    submitBtn.disabled = false
                    return
                }

                // Reiniciar selección si ya había rango
                this.resetCalendarColors(calendarEl)
                startDate = clickedDate
                endDate = null
                startInput.value = clickedDate
                endInput.value = ""
                this.highlightDate(info.dayEl, "#0d6efd")
                messageEl.textContent = "📅 Ahora selecciona la nueva fecha de fin (o guarda si es solo un día)."
                submitBtn.disabled = false
            }
        })

        calendar.render()

        // 🔴 Pintar fechas reservadas (de otros usuarios)
        this.disabledRangesValue.forEach(range => {
            const start = new Date(range.start)
            const end = new Date(range.end)
            for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
                const dateStr = d.toISOString().split("T")[0]
                const el = calendarEl.querySelector(`[data-date="${dateStr}"]`)
                if (el) {
                    el.style.backgroundColor = "#ffcccc"
                    el.style.color = "#000"
                    el.title = "Reservado"
                }
            }
        })

        // 💙 Mostrar la reserva actual
        if (startDate && endDate) {
            const start = new Date(startDate)
            const end = new Date(endDate)
            for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
                const dateStr = d.toISOString().split("T")[0]
                const el = calendarEl.querySelector(`[data-date="${dateStr}"]`)
                if (el) {
                    el.style.backgroundColor = "#0dcaf0" // Celeste
                    el.style.color = "#fff"
                    el.style.border = "1px solid #0b5ed7"
                    el.style.borderRadius = "6px"
                    el.title = "Tu reserva actual"
                }
            }
        }

        // ✅ Si solo se elige una fecha, end_date se iguala al start_date antes de enviar
        const form = this.element.querySelector("form")
        if (form) {
            form.addEventListener("submit", () => {
                if (startInput.value && !endInput.value) {
                    endInput.value = startInput.value
                }
            })
        }
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
                el.style.borderRadius = "4px"
            }
        }
    }

    resetCalendarColors(calendarEl) {
        const days = calendarEl.querySelectorAll("[data-date]")
        days.forEach((el) => {
            if (!this.isDisabled(el.dataset.date)) {
                el.style.backgroundColor = ""
                el.style.color = ""
                el.style.border = ""
            }
        })

        // Repintar las fechas reservadas
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
