module HotelsHelper
  def hotel_type_label(type)
    {
      "conventional" => "Hotel convencional",
      "boutique" => "Hotel boutique",
      "chain" => "Hotel de cadena",
      "resort" => "Resort",
      "ecohotel" => "Ecohotel / Ecolodge"
    }[type] || type
  end

  def calculate_profile_completion(hotel)
    total_points = 0
    completed_points = 0

    total_points += 3
    completed_points += 1 if hotel.establishment.name.present?
    completed_points += 1 if hotel.hotel_type.present?
    completed_points += 1 if hotel.stars.present?

    legal_info = hotel.establishment.legal_info
    total_points += 5
    completed_points += 1 if legal_info.business_name.present?
    completed_points += 1 if legal_info.document_number.present?
    completed_points += 1 if legal_info.legal_representative.present?
    completed_points += 1 if legal_info.contact_email.present?
    completed_points += 1 if legal_info.contact_phone.present?

    total_points += 4
    completed_points += 1 if hotel.establishment.country.present?
    completed_points += 1 if hotel.establishment.province.present?
    completed_points += 1 if hotel.establishment.city.present?
    completed_points += 1 if hotel.establishment.address.present?

    total_points += 2
    completed_points += 1 if hotel.establishment.galleries.any?
    completed_points += 1 if hotel.units.any?

    ((completed_points.to_f / total_points) * 100).round
  end
end
