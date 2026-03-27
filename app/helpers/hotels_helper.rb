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
end
