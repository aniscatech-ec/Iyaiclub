import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "hotelsContainer", "checkbox", "resultsCount",
        "minPrice", "maxPrice", "minPriceValue", "maxPriceValue",
        "resultsTotal", "resultsRange", "sliderWrapper"
    ]

    connect() {
        // Inicial valores/visual del slider si existen
        if (this.hasMinPriceTarget && this.hasMaxPriceTarget) {
            // muestra valores iniciales
            if (this.hasMinPriceValueTarget) this.minPriceValueTarget.textContent = this.minPriceTarget.value
            if (this.hasMaxPriceValueTarget) this.maxPriceValueTarget.textContent = this.maxPriceTarget.value

            this.updateSliderVisuals()

            // escucha cambios "input" (por si otro código los cambia)
            this.minPriceTarget.addEventListener("input", () => this.updateSliderVisuals())
            this.maxPriceTarget.addEventListener("input", () => this.updateSliderVisuals())

            // inicializa la lógica de pointer (click + drag)
            this.initCustomSlider()
        }

        // checkboxes -> aplicar filtros
        if (this.hasCheckboxTarget) {
            this.checkboxTargets.forEach(cb => cb.addEventListener("change", () => this.applyFilters()))
        }

        // enlaza paginación
        this.bindPaginationLinks()
    }

    // ------------------ SLIDER CUSTOM: click + drag seguro ------------------
    initCustomSlider() {
        if (!this.hasSliderWrapperTarget) return

        const wrapper = this.sliderWrapperTarget
        const minInput = this.minPriceTarget
        const maxInput = this.maxPriceTarget
        const step = Number(minInput.step) || 1
        const minAllowed = Number(minInput.min) || 0
        const maxAllowed = Number(minInput.max) || 1000
        const thumbGrabPx = 14 // umbral para "agarrar" el thumb (px)
        const minGap = step      // separación mínima entre min y max (puedes ajustar)

        let dragging = false
        let draggingThumb = null
        let activePointerId = null

        const valueFromClientX = (clientX) => {
            const rect = wrapper.getBoundingClientRect()
            let pct = (clientX - rect.left) / rect.width
            pct = Math.max(0, Math.min(1, pct))
            const raw = minAllowed + pct * (maxAllowed - minAllowed)
            const stepped = Math.round(raw / step) * step
            return Math.min(Math.max(stepped, minAllowed), maxAllowed)
        }

        const percentFromValue = (v) => ((v - minAllowed) / (maxAllowed - minAllowed)) * 100

        // pointermove handler (se añadirá solo durante el drag)
        const onPointerMove = (ev) => {
            if (!dragging || ev.pointerId !== activePointerId) return
            ev.preventDefault()
            const val = valueFromClientX(ev.clientX)
            const curMin = Number(minInput.value)
            const curMax = Number(maxInput.value)

            if (draggingThumb === 'min') {
                const newMin = Math.min(val, curMax - minGap)
                minInput.value = newMin
                minInput.dispatchEvent(new Event('input', { bubbles: true }))
            } else if (draggingThumb === 'max') {
                const newMax = Math.max(val, curMin + minGap)
                maxInput.value = newMax
                maxInput.dispatchEvent(new Event('input', { bubbles: true }))
            }
            this.updateSliderVisuals()
        }

        const onPointerUp = (ev) => {
            if (!dragging || ev.pointerId !== activePointerId) return
            try { wrapper.releasePointerCapture(activePointerId) } catch (err) {}
            dragging = false
            draggingThumb = null
            activePointerId = null
            document.removeEventListener('pointermove', onPointerMove)
            document.removeEventListener('pointerup', onPointerUp)
        }

        // pointerdown: decide si iniciar drag o mover el thumb más cercano (click en track)
        wrapper.addEventListener('pointerdown', (e) => {
            // solo botón principal
            if (e.button !== 0) return

            const rect = wrapper.getBoundingClientRect()
            const clickX = e.clientX - rect.left
            const width = rect.width
            const minPx = (Number(minInput.value) - minAllowed) / (maxAllowed - minAllowed) * width
            const maxPx = (Number(maxInput.value) - minAllowed) / (maxAllowed - minAllowed) * width
            const distToMinPx = Math.abs(clickX - minPx)
            const distToMaxPx = Math.abs(clickX - maxPx)

            // Si está cerca de alguno de los thumbs => iniciar drag de ese thumb
            if (distToMinPx <= thumbGrabPx || distToMaxPx <= thumbGrabPx) {
                dragging = true
                draggingThumb = (distToMinPx <= distToMaxPx) ? 'min' : 'max'
                activePointerId = e.pointerId
                try { wrapper.setPointerCapture(e.pointerId) } catch (_) {}
                document.addEventListener('pointermove', onPointerMove)
                document.addEventListener('pointerup', onPointerUp)
                // impedir text select, etc.
                e.preventDefault()
                return
            }

            // Si no está cerca de un thumb -> click en track: mover thumb más cercano al valor clicado
            const clickedValue = valueFromClientX(e.clientX)
            const curMin = Number(minInput.value)
            const curMax = Number(maxInput.value)
            const distMin = Math.abs(clickedValue - curMin)
            const distMax = Math.abs(clickedValue - curMax)

            if (distMin <= distMax) {
                minInput.value = Math.min(clickedValue, curMax - minGap)
                minInput.dispatchEvent(new Event('input', { bubbles: true }))
            } else {
                maxInput.value = Math.max(clickedValue, curMin + minGap)
                maxInput.dispatchEvent(new Event('input', { bubbles: true }))
            }

            this.updateSliderVisuals()
            // no iniciar drag al click en track (evita comportamiento inesperado)
        })
    }

    // ------------------ actualiza la barra azul y valores ------------------
    updateSliderVisuals() {
        if (!this.hasMinPriceTarget || !this.hasMaxPriceTarget) return

        const min = Number(this.minPriceTarget.value)
        const max = Number(this.maxPriceTarget.value)
        const rangeMin = Number(this.minPriceTarget.min) || 0
        const rangeMax = Number(this.minPriceTarget.max) || 1000

        const minPercent = ((min - rangeMin) / (rangeMax - rangeMin)) * 100
        const maxPercent = ((max - rangeMin) / (rangeMax - rangeMin)) * 100

        const sliderRange = this.sliderWrapperTarget.querySelector(".slider-range")
        if (sliderRange) {
            sliderRange.style.left = `${minPercent}%`
            sliderRange.style.width = `${(maxPercent - minPercent)}%`
        }

        if (this.hasMinPriceValueTarget) this.minPriceValueTarget.textContent = min
        if (this.hasMaxPriceValueTarget) this.maxPriceValueTarget.textContent = max
    }

    // ------------------ resto del controlador (sin cambios lógicos) ------------------
    buildParams() {
        const params = new URLSearchParams()
        if (this.hasCheckboxTarget) {
            const selected = this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)
            selected.forEach(id => params.append("amenities[]", id))
        }
        if (this.hasMinPriceTarget && this.hasMaxPriceTarget) {
            params.append("min_price", this.minPriceTarget.value)
            params.append("max_price", this.maxPriceTarget.value)
        }
        const cityInput = document.querySelector('input[name="city"]')
        if (cityInput && cityInput.value.trim() !== "") params.append("city", cityInput.value.trim())
        const checkinInput = document.querySelector('input[name="checkin"]')
        const checkoutInput = document.querySelector('input[name="checkout"]')
        if (checkinInput && checkinInput.value) params.append("checkin", checkinInput.value)
        if (checkoutInput && checkoutInput.value) params.append("checkout", checkoutInput.value)
        return params.toString()
    }

    async applyFilters() {
        const qs = this.buildParams()
        const url = `/hotels?${qs}`
        if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = "Cargando..."
        if (this.hasResultsRangeTarget) this.resultsRangeTarget.textContent = ""
        if (this.hasHotelsContainerTarget) this.hotelsContainerTarget.innerHTML = "<p class='text-center p-3'>Cargando hoteles...</p>"

        try {
            const res = await fetch(url, { headers: { "X-Requested-With": "XMLHttpRequest" } })
            if (!res.ok) throw new Error("network error")
            const html = await res.text()
            if (this.hasHotelsContainerTarget) this.hotelsContainerTarget.innerHTML = html
            this.updateResultsFromMeta()
            history.pushState(null, "", url)
            this.bindPaginationLinks()
        } catch (e) {
            console.error(e)
            if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = "Error"
            if (this.hasHotelsContainerTarget) this.hotelsContainerTarget.innerHTML = "<p class='text-danger'>Error cargando hoteles</p>"
        }
    }

    filterByPrice() { this.applyFilters() }

    updateResultsFromMeta() {
        if (!this.hasHotelsContainerTarget) return
        const meta = this.hotelsContainerTarget.querySelector("#hotels-meta")
        if (meta && meta.dataset.total) {
            const total = parseInt(meta.dataset.total, 10) || 0
            const offset = parseInt(meta.dataset.offset, 10) || 0
            const length = parseInt(meta.dataset.length, 10) || 0
            const start = total === 0 ? 0 : offset + 1
            const end = Math.min(offset + length, total)
            if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = `${total}`
            if (this.hasResultsRangeTarget) this.resultsRangeTarget.textContent = `Mostrando ${start} – ${end}`
        } else {
            const count = this.hotelsContainerTarget.querySelectorAll(".hotel-card").length
            if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = `${count}`
            if (this.hasResultsRangeTarget) this.resultsRangeTarget.textContent = `Mostrando ${count}`
        }
    }

    bindPaginationLinks() {
        if (!this.hasHotelsContainerTarget) return
        const links = this.hotelsContainerTarget.querySelectorAll(".pagination a")
        links.forEach(link => {
            if (link._handler) link.removeEventListener("click", link._handler)
            const handler = (e) => {
                e.preventDefault()
                const href = link.getAttribute("href")
                if (!href) return
                if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = "Cargando..."
                if (this.hasResultsRangeTarget) this.resultsRangeTarget.textContent = ""
                this.hotelsContainerTarget.innerHTML = "<p class='text-center p-3'>Cargando hoteles...</p>"
                fetch(href, { headers: { "X-Requested-With": "XMLHttpRequest" } })
                    .then(res => {
                        if (!res.ok) throw new Error("network error")
                        return res.text()
                    })
                    .then(html => {
                        this.hotelsContainerTarget.innerHTML = html
                        this.updateResultsFromMeta()
                        history.pushState(null, "", href)
                        this.bindPaginationLinks()
                    })
                    .catch(err => {
                        console.error(err)
                        if (this.hasResultsTotalTarget) this.resultsTotalTarget.textContent = "Error"
                        this.hotelsContainerTarget.innerHTML = "<p class='text-danger'>Error cargando hoteles</p>"
                    })
            }
            link.addEventListener("click", handler)
            link._handler = handler
        })
    }
}
