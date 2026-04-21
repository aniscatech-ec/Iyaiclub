import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    ticketId: Number,
    checkUrl: String,
    expiresAt: Number,
    ticketsUrl: String
  }

  static targets = ["timer", "status", "loader"]

  connect() {
    if (this.hasTimerTarget && this.expiresAtValue > 0) {
      this.startCountdown()
    }
    this.startPolling()
  }

  disconnect() {
    if (this.countdownInterval) clearInterval(this.countdownInterval)
    if (this.pollInterval) clearInterval(this.pollInterval)
  }

  startCountdown() {
    this.updateTimer()
    this.countdownInterval = setInterval(() => {
      this.updateTimer()
    }, 1000)
  }

  updateTimer() {
    if (!this.hasTimerTarget) return

    const now = Math.floor(Date.now() / 1000)
    const remaining = this.expiresAtValue - now

    if (remaining <= 0) {
      clearInterval(this.countdownInterval)
      clearInterval(this.pollInterval)
      this.timerTarget.textContent = "00:00"
      this.timerTarget.classList.add("text-danger")
      if (this.hasStatusTarget) {
        this.statusTarget.innerHTML =
          '<div class="alert alert-danger text-center">' +
          '<i class="fas fa-times-circle me-2"></i>' +
          '<strong>La reserva ha expirado.</strong> El ticket fue cancelado por falta de confirmación.' +
          '</div>'
      }
      if (this.hasLoaderTarget) {
        this.loaderTarget.style.display = "none"
      }
      return
    }

    const minutes = Math.floor(remaining / 60)
    const seconds = remaining % 60
    this.timerTarget.textContent =
      `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`

    if (remaining <= 120) {
      this.timerTarget.classList.add("text-danger")
    } else if (remaining <= 300) {
      this.timerTarget.classList.add("text-warning")
    }
  }

  startPolling() {
    this.pollInterval = setInterval(async () => {
      try {
        const response = await fetch(this.checkUrlValue, {
          headers: { "Accept": "application/json" }
        })
        const data = await response.json()

        if (data.status === "activo") {
          clearInterval(this.countdownInterval)
          clearInterval(this.pollInterval)
          if (this.hasStatusTarget) {
            this.statusTarget.innerHTML =
              '<div class="alert alert-success text-center">' +
              '<i class="fas fa-check-circle fa-2x mb-2 d-block"></i>' +
              '<strong>¡Tu ticket ha sido acreditado exitosamente!</strong><br>' +
              'Recibirás tu ticket en PDF por email. Redirigiendo...' +
              '</div>'
          }
          if (this.hasLoaderTarget) {
            this.loaderTarget.style.display = "none"
          }
          setTimeout(() => {
            window.location.href = this.ticketsUrlValue
          }, 2500)
        } else if (data.status === "cancelado") {
          clearInterval(this.countdownInterval)
          clearInterval(this.pollInterval)
          if (this.hasStatusTarget) {
            this.statusTarget.innerHTML =
              '<div class="alert alert-danger text-center">' +
              '<i class="fas fa-times-circle me-2"></i>' +
              '<strong>La reserva fue cancelada o rechazada.</strong>' +
              '</div>'
          }
          if (this.hasLoaderTarget) {
            this.loaderTarget.style.display = "none"
          }
        }
      } catch (e) {
        console.error("Error polling ticket status:", e)
      }
    }, 5000)
  }
}
