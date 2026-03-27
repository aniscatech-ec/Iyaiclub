module ApplicationHelper
  def whatsapp_link(phone, message = nil)
    return nil if phone.blank?

    sanitized = phone.to_s.gsub(/[^\d+]/, "")
    sanitized = sanitized.delete("+")
    url = "https://wa.me/#{sanitized}"
    url += "?text=#{ERB::Util.url_encode(message)}" if message.present?
    url
  end
end
