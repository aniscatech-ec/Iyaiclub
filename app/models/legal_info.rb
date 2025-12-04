class LegalInfo < ApplicationRecord
  belongs_to :establishment
  attr_accessor :country_code

  before_save :format_phone

  private

  def format_phone
    return if contact_phone.blank?

    digits = contact_phone.gsub(/\D/, '')
    code   = country_code.presence || "593"  # default Ecuador

    self.contact_phone = "#{code}#{digits}"
  end

end
