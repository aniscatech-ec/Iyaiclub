// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import DropdownHoverController from "controllers/dropdown_hover_controller"
import AffiliateController from "controllers/affiliate_controller"
import FormValidationController from "controllers/form_validation_controller"
import MapDisplayController from "controllers/map_display_controller"
import LocationUserController from "controllers/location_user_controller"
import NestedFormController from "controllers/nested_form_controller"
import GalleryController from "controllers/gallery_controller"
import PayphoneController from "controllers/payphone_controller"
import QrScannerController from "controllers/qr_scanner_controller"
import TransferStatusController from "controllers/transfer_status_controller"
import PurchaseFormController from "controllers/purchase_form_controller"
import PasswordToggleController from "controllers/password_toggle_controller"
import FreeEntryController from "controllers/free_entry_controller"
import RegistrationRoleController from "controllers/registration_role_controller"
import LocationSelectController from "controllers/location_select_controller"

application.register("dropdown-hover", DropdownHoverController)
application.register("affiliate", AffiliateController)
application.register("form-validation", FormValidationController)
application.register("map-display", MapDisplayController)
application.register("location-user", LocationUserController)
application.register("nested-form", NestedFormController)
application.register("gallery", GalleryController)
application.register("payphone", PayphoneController)
application.register("qr-scanner", QrScannerController)
application.register("transfer-status", TransferStatusController)
application.register("purchase-form", PurchaseFormController)
application.register("password-toggle", PasswordToggleController)
application.register("free-entry", FreeEntryController)
application.register("registration-role", RegistrationRoleController)
application.register("location-select", LocationSelectController)
