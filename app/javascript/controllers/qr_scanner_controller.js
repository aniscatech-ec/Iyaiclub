import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "result", "status", "ticketInfo", "manualInput"]
  static values = { verifyUrl: String, markUsedUrl: String }

  connect() {
    console.log("QrScannerController connected!")
    this.scanning = false
    this.html5QrCode = null
  }

  disconnect() {
    this.stopScanner()
  }

  async startScanner() {
    console.log("startScanner called")
    if (this.scanning) {
      console.log("Already scanning")
      return
    }

    try {
      // html5-qrcode se carga como script global desde CDN
      if (typeof window.Html5Qrcode === "undefined") {
        console.error("Html5Qrcode not loaded")
        throw new Error("Html5Qrcode library not loaded")
      }
      this.html5QrCode = new window.Html5Qrcode("qr-reader")

      this.statusTarget.innerHTML = `
        <div class="d-flex align-items-center gap-2">
          <div class="spinner-border spinner-border-sm text-primary" role="status"></div>
          <span>Escaneando...</span>
        </div>
      `

      await this.html5QrCode.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 250, height: 250 } },
        (decodedText) => { this.onScanSuccess(decodedText) },
        () => {}
      )

      this.scanning = true
    } catch (err) {
      console.error("Camera error:", err.name, err.message)
      this.statusTarget.innerHTML = `
        <div class="alert alert-warning mb-0">
          <i class="fas fa-exclamation-triangle me-1"></i>
          No se pudo acceder a la cámara (${err.name}). Usa la entrada manual.
        </div>
      `
    }
  }

  async stopScanner() {
    if (this.html5QrCode && this.scanning) {
      try {
        await this.html5QrCode.stop()
      } catch (e) {}
      this.scanning = false
    }
  }

  onScanSuccess(decodedText) {
    // Detener escáner inmediatamente al detectar un código
    this.stopScanner()

    console.log("QR detectado:", decodedText)

    let ticketCode = null

    try {
      // Intentar parsear como JSON primero
      const data = JSON.parse(decodedText)
      if (data && data.ticket) {
        ticketCode = data.ticket
      }
    } catch (e) {
      // Si no es JSON válido, verificar si es un código EXP- directamente
      if (decodedText && decodedText.startsWith("EXP-")) {
        ticketCode = decodedText
      }
    }

    if (ticketCode) {
      this.verifyTicket(ticketCode)
    } else {
      this.showResult({ error: "QR no válido o no reconocido" })
      // Reiniciar escáner después de 2 segundos
      setTimeout(() => this.startScanner(), 2000)
    }
  }

  verifyManual(event) {
    console.log("verifyManual called", event)
    if (event) event.preventDefault()

    if (!this.hasManualInputTarget) {
      console.error("manualInput target not found")
      return
    }

    const code = this.manualInputTarget.value.trim()
    console.log("Código ingresado:", code)

    if (!code) {
      this.showResult({ error: "Por favor ingresa un código de ticket" })
      return
    }

    this.verifyTicket(code)
  }

  verifyManualKey(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.verifyManual()
    }
  }

  async verifyTicket(ticketCode) {
    this.statusTarget.innerHTML = `
      <div class="d-flex align-items-center gap-2">
        <div class="spinner-border spinner-border-sm text-primary" role="status"></div>
        <span>Verificando ticket...</span>
      </div>
    `

    try {
      const csrfToken = document.querySelector("[name='csrf-token']")?.content
      const response = await fetch(this.verifyUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ ticket_code: ticketCode })
      })

      const data = await response.json()
      this.showResult(data)
    } catch {
      this.showResult({ error: "Error de conexión" })
    }
  }

  showResult(data) {
    if (data.error) {
      this.statusTarget.innerHTML = `
        <div class="alert alert-danger mb-0">
          <i class="fas fa-times-circle me-1"></i> ${data.error}
        </div>
      `
      this.ticketInfoTarget.innerHTML = ""
      return
    }

    const statusClass = data.status === "activo" ? "success" : data.status === "usado" ? "secondary" : "danger"
    const statusIcon = data.status === "activo" ? "check-circle" : data.status === "usado" ? "minus-circle" : "times-circle"
    const statusLabel = data.status === "activo" ? "VÁLIDO" : data.status === "usado" ? "YA USADO" : "CANCELADO"

    this.statusTarget.innerHTML = `
      <div class="alert alert-${statusClass} mb-0 d-flex align-items-center gap-2" style="font-size: 1.1rem;">
        <i class="fas fa-${statusIcon} fa-2x"></i>
        <div>
          <strong>${statusLabel}</strong>
          ${data.status === "activo" ? `<br><small>Ticket válido para ingreso</small>` : ""}
          ${data.status === "usado" ? `<br><small>Usado el ${data.used_at}</small>` : ""}
        </div>
      </div>
    `

    this.ticketInfoTarget.innerHTML = `
      <div class="card border-0 bg-light rounded-3 p-3">
        <div class="row g-2">
          <div class="col-6">
            <small class="text-muted d-block">Código</small>
            <strong style="color: #2E7D32;">${data.ticket_code}</strong>
          </div>
          <div class="col-6">
            <small class="text-muted d-block">N° Rifa</small>
            <strong class="text-warning">${data.raffle_number}</strong>
          </div>
          <div class="col-12">
            <small class="text-muted d-block">Asistente</small>
            <strong>${data.guest_name}</strong>
          </div>
          <div class="col-12">
            <small class="text-muted d-block">Evento</small>
            <strong>${data.event_name}</strong>
          </div>
        </div>
        ${data.status === "activo" ? `
          <div class="mt-3">
            <button class="btn btn-success w-100" data-action="qr-scanner#markAsUsed" data-ticket-id="${data.id}">
              <i class="fas fa-check me-1"></i> Marcar como Usado
            </button>
          </div>
        ` : ""}
      </div>
    `
  }

  async markAsUsed(event) {
    const ticketId = event.currentTarget.dataset.ticketId
    const csrfToken = document.querySelector("[name='csrf-token']")?.content

    console.log("Marking ticket as used:", ticketId)
    console.log("URL:", `${this.markUsedUrlValue}/${ticketId}/mark_used`)

    try {
      const response = await fetch(`${this.markUsedUrlValue}/${ticketId}/mark_used`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })

      const data = await response.json()
      if (data.success) {
        this.statusTarget.innerHTML = `
          <div class="alert alert-success mb-0">
            <i class="fas fa-check-circle me-1"></i> Ticket marcado como usado correctamente.
          </div>
        `
        this.ticketInfoTarget.innerHTML = `
          <div class="text-center py-3">
            <i class="fas fa-check-circle fa-3x text-success mb-2"></i>
            <h5 class="fw-bold text-success">Ticket verificado y registrado</h5>
            <button class="btn btn-outline-primary mt-2" data-action="qr-scanner#reset">
              <i class="fas fa-redo me-1"></i> Escanear otro ticket
            </button>
          </div>
        `
      } else {
        this.statusTarget.innerHTML = `
          <div class="alert alert-danger mb-0">
            <i class="fas fa-times-circle me-1"></i> ${data.error || "Error al marcar el ticket"}
          </div>
        `
      }
    } catch {
      this.statusTarget.innerHTML = `
        <div class="alert alert-danger mb-0">Error de conexión</div>
      `
    }
  }

  async reset() {
    this.statusTarget.innerHTML = ""
    this.ticketInfoTarget.innerHTML = ""
    if (this.manualInputTarget) this.manualInputTarget.value = ""
    await this.startScanner()
  }
}
