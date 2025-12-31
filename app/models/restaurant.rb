class Restaurant < ApplicationRecord
  belongs_to :establishment

  has_many :restaurant_menu_categories #tabla intermedia
  has_many :menu_categories, through: :restaurant_menu_categories # relacion *-*

  has_many :menu_items
  has_many :restaurant_hours, dependent: :destroy

  # Horario del día actual
  def today_hour
    restaurant_hours.find_by(day_of_week: Time.zone.today.wday)
  end

  def open_now?
    hour = today_hour
    return false if hour.nil? || hour.closed?

    now = Time.zone.now.strftime('%H:%M')

    now >= hour.open_time.strftime('%H:%M') &&
      now <= hour.close_time.strftime('%H:%M')
  end

  def today_schedule_text
    hour = today_hour
    return 'Horario no disponible' if hour.nil?
    # return 'Cerrado hoy' if hour.closed?
    return 'Cerrado' if hour.closed?

    "#{hour.open_time.strftime('%H:%M')} - #{hour.close_time.strftime('%H:%M')}"
  end

  def closes_soon?
    hour = today_hour
    return false if hour.nil? || hour.closed?

    now = Time.zone.now
    close_time = Time.zone.parse(hour.close_time.strftime('%H:%M'))

    (close_time - now) <= 1.hour && close_time > now
  end

  def closed_now?
    !open_now?
  end



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
  # accepts_nested_attributes_for :units
  # accepts_nested_attributes_for :galleries
  accepts_nested_attributes_for :establishment
end
