import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "select2"

// Conectar Stimulus a select2
export default class extends Controller {
    connect() {
        console.log("Connected to select2 controller...")
        this.initSelect2()
    }

    disconnect() {
        // Evita duplicados al navegar con Turbo
        if ($(this.element).data("select2")) {
            $(this.element).select2("destroy")
        }
    }

    initSelect2() {
        const ajaxUrl = this.element.dataset.url

        $(this.element).select2({
            placeholder: this.element.dataset.placeholder || "Seleccionar...",
            allowClear: true,
            width: "100%",
            ajax: {
                url: ajaxUrl,
                dataType: "json",
                delay: 250,
                data: function (params) {
                    return { q: params.term } // lo que escribe el usuario
                },
                processResults: function (data) {
                    return {
                        results: data.map(user => ({
                            id: user.id,
                            text: `${user.name} (${user.email})`
                        }))
                    }
                },
                cache: true
            }
        })
    }
}
