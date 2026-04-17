// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import DropdownHoverController from "./dropdown_hover_controller"
import AffiliateController from "./affiliate_controller"
import FormValidationController from "./form_validation_controller"
import MapDisplayController from "./map_display_controller"
import LocationUserController from "./location_user_controller"
import NestedFormController from "./nested_form_controller"
import GalleryController from "./gallery_controller"
import PayphoneController from "./payphone_controller"
import QrScannerController from "./qr_scanner_controller"
import TransferStatusController from "./transfer_status_controller"
import PurchaseFormController from "./purchase_form_controller"

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
