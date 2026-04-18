// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Deshabilitar Turbo en todos los formularios de Devise para que los
// mensajes de error/validación se muestren correctamente.
document.addEventListener("turbo:load", () => {
  document.querySelectorAll("form[action*='/users']").forEach(form => {
    form.dataset.turbo = "false"
  })
})

