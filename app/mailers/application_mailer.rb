class ApplicationMailer < ActionMailer::Base
  LOGO_CID = "iyaiclub-logo@iyaiclub.com".freeze

  default from: "IyaiClub <info@iyaiclub.com>",
          reply_to: "info@iyaiclub.com",
          "X-Mailer": "IyaiClub",
          "List-Unsubscribe": "<mailto:info@iyaiclub.com?subject=Unsubscribe>",
          "List-Unsubscribe-Post": "List-Unsubscribe=One-Click"

  layout "mailer"

  # Adjuntar logo inline a todos los emails
  before_action :attach_inline_logo

  helper_method :logo_cid

  def logo_cid
    LOGO_CID
  end

  private

  def attach_inline_logo
    logo_path = Rails.root.join("app/assets/images/logo.jpeg")
    return unless File.exist?(logo_path)

    attachments.inline["logo.jpeg"] = {
      data: File.read(logo_path),
      mime_type: "image/jpeg",
      content_id: "<#{LOGO_CID}>"
    }
  end
end
