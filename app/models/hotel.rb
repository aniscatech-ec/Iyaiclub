class Hotel < ApplicationRecord
  belongs_to :establishment

  enum :hotel_type, {
    hotel: "hotel",
    hostal: "hostal",
    glamping: "glamping",
    ecohotel: "ecohotel",
    alojamiento_temporal: "alojamiento_temporal"
  }

  delegate :user,
           :images,
           :establishment_amenities,
           :amenities,
           :units,
           :galleries,
           :payment_methods,
           :legal_info,
           :verification,
           :pricing_policy,
           to: :establishment
  accepts_nested_attributes_for :establishment
end
