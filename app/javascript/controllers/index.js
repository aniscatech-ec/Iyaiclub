// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import DropdownHoverController from "./dropdown_hover_controller"
import AffiliateController from "./affiliate_controller"

application.register("dropdown-hover", DropdownHoverController)
application.register("affiliate", AffiliateController)
