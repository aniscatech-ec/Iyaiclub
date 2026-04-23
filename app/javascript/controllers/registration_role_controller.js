import { Controller } from "@hotwired/stimulus"

// Muestra/oculta la sección de documentos según el rol seleccionado.
// En el form de registro público los documentos son obligatorios para afiliados.
// En el form de admin (data-registration-role-admin) son opcionales.
export default class extends Controller {
  static targets = ["roleSelect", "docsSection", "docInput"]
  static values  = { adminMode: Boolean }

  connect() {
    this.toggleDocs()
  }

  toggleDocs() {
    const isAfiliado = this.roleSelectTarget.value === "afiliado"
    this.docsSectionTarget.style.display = isAfiliado ? "block" : "none"
    // En modo admin los documentos no son obligatorios (el afiliado puede subirlos después)
    const makeRequired = isAfiliado && !this.adminModeValue
    this.docInputTargets.forEach(input => {
      input.required = makeRequired
    })
  }
}
