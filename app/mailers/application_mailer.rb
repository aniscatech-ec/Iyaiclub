class ApplicationMailer < ActionMailer::Base
  default from: "IyaiClub <info@iyaiclub.com>",
          reply_to: "info@iyaiclub.com",
          "X-Mailer": "IyaiClub",
          "List-Unsubscribe": "<mailto:info@iyaiclub.com?subject=Unsubscribe>",
          "List-Unsubscribe-Post": "List-Unsubscribe=One-Click"

  layout "mailer"

  # Adjuntar logo a todos los emails
  before_action :attach_logo

  private

  def attach_logo
    logo_path = Rails.root.join("app/assets/images/logo.jpeg")
    return unless File.exist?(logo_path)

    attachments.inline["logo"] = {
      data: File.read(logo_path),
      mime_type: "image/jpeg"
    }
  end
end
