# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "flatpickr" # @4.6.13

# pin "leaflet", to: "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet-src.esm.js"


# FullCalendar core y plugins
# pin "@fullcalendar/core", to: "https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.19/index.js"
# pin "@fullcalendar/daygrid", to: "https://cdn.jsdelivr.net/npm/@fullcalendar/daygrid@6.1.19/index.js"
# pin "@fullcalendar/interaction", to: "https://cdn.jsdelivr.net/npm/@fullcalendar/interaction@6.1.19/index.js"
# pin "@fullcalendar/core/locales-all", to: "https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.19/locales-all.js"
#
# pin "preact", to: "https://cdn.jsdelivr.net/npm/preact@10.22.0/dist/preact.module.js"
# pin "preact/hooks", to: "https://cdn.jsdelivr.net/npm/preact@10.22.0/hooks/dist/hooks.module.js"




pin "jquery" # @3.7.1
pin "select2" # @4.1.0
pin "html5-qrcode", to: "https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js"
