import { Controller } from "@hotwired/stimulus"

// Muestra/oculta la sección de documentos según el rol seleccionado.
// Si el rol es "afiliado", los campos de documento son obligatorios.
export default class extends Controller {
  static targets = ["roleSelect", "docsSection", "docInput"]

  connect() {
    this.toggleDocs()
  }

  toggleDocs() {
    const isAfiliado = this.roleSelectTarget.value === "afiliado"
    this.docsSectionTarget.style.display = isAfiliado ? "block" : "none"
    this.docInputTargets.forEach(input => {
      input.required = isAfiliado
    })
  }
}
