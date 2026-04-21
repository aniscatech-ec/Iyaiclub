class ApplicationMailer < ActionMailer::Base
  default from: "IyaiClub <info@iyaiclub.com>",
          reply_to: "info@iyaiclub.com",
          "X-Mailer": "IyaiClub",
          "List-Unsubscribe": "<mailto:info@iyaiclub.com?subject=Unsubscribe>",
          "List-Unsubscribe-Post": "List-Unsubscribe=One-Click"

  layout "mailer"

  # Adjuntar logo inline a todos los emails
  before_action :attach_inline_logo

  private

  def attach_inline_logo
    logo_path = Rails.root.join("app/assets/images/logo.jpeg")
    return unless File.exist?(logo_path)

    attachments.inline["logo.jpeg"] = File.binread(logo_path)
  rescue => e
    Rails.logger.error("[Mailer] Error adjuntando logo: #{e.message}")
  end
end
