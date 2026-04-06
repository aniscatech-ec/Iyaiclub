// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import DropdownHoverController from "./dropdown_hover_controller"
import AffiliateController from "./affiliate_controller"
import FormValidationController from "./form_validation_controller"
import MapDisplayController from "./map_display_controller"
import LocationUserController from "./location_user_controller"

application.register("dropdown-hover", DropdownHoverController)
application.register("affiliate", AffiliateController)
application.register("form-validation", FormValidationController)
application.register("map-display", MapDisplayController)
application.register("location-user", LocationUserController)
