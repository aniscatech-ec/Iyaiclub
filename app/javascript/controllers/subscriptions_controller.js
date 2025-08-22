import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="subscriptions"
export default class extends Controller {
    static targets = ["paymentMethod", "paymentInstructions", "userId", "establishmentId","selectRole"]

    connect() {
        console.log("Conectado con stimulus");
    }


    updatePaymentInstructions() {
        console.log("updatePaymentInstructions");
        const method = this.paymentMethodTarget.value
        let text = ""

        switch (method) {
            case "transferencia":
                text = "Deposite el valor en la cuenta bancaria XYZ. Envíe el comprobante a pagos@tuempresa.com"
                break
            case "efectivo":
                text = "Acérquese a nuestras oficinas para cancelar en efectivo."
                break
            case "tarjeta":
                text = "Ingrese los datos de su tarjeta en la pasarela de pago."
                break
            default:
                text = ""
        }

        this.paymentInstructionsTarget.value = text
    }

    updateEstablishment() {
        console.log("updateEstablishment");

        const userId = this.userIdTarget.value
        if (!userId) {
            this.establishmentIdTarget.innerHTML = "<option value=''>Seleccione un establecimiento</option>";
            return;
        }
        const url = `/admin/users/${userId}/establishments.json`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                this.establishmentIdTarget.innerHTML = "<option value=''>Seleccione un establecimiento</option>";
                data.forEach(est => {
                    let option = document.createElement("option");
                    option.value = est.id;
                    option.textContent = est.name;
                    this.establishmentIdTarget.appendChild(option);
                });
            })
            .catch(error => console.error("Error cargando establecimientos:", error));
    }

    updateRoleUsers(){
        console.log("updateRole");

        const role = this.selectRoleTarget.value
        if (!role) {
            this.userIdTarget.innerHTML = "<option value=''>Seleccione un usuario</option>";
            return;
        }
        const url = `/admin/users/users_by_role?role=${role}`
        // const url = `/admin/users/by_role/${role}/users.json`

        fetch(url)
            .then(response => response.json())
            .then(data => {
                this.userIdTarget.innerHTML = "<option value=''>Seleccione un usuario</option>";
                this.establishmentIdTarget.innerHTML = "<option value=''>Seleccione un establecimiento</option>";

                data.forEach(est => {
                    let option = document.createElement("option");
                    option.value = est.id;
                    option.textContent = est.name;
                    this.userIdTarget.appendChild(option);
                });
            })
            .catch(error => console.error("Error cargando establecimientos:", error));
    }
}
