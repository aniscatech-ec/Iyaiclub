class ApplicationMailer < ActionMailer::Base
  default from: "IyaiClub <info@iyaiclub.com>"
  layout "mailer"
  
  # Adjuntar logo a todos los emails
  before_action :attach_logo
  
  private
  
  def attach_logo
    attachments.inline['logo'] = {
      data: File.read(Rails.root.join('app/assets/images/logo.jpeg')),
      mime_type: 'image/jpeg'
    }
  end
end
