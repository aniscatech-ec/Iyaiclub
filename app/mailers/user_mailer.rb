class UserMailer < ApplicationMailer
  # Enviar correo de bienvenida después de confirmar cuenta
  def welcome_email(user)
    @user = user
    @membership = user.active_membership
    
    mail(
      to: @user.email,
      subject: '¡Bienvenido a IyaiClub! Tu cuenta está lista',
      from: email_from(:info)
    )
  end

  # Enviar notificación de reserva (opcional)
  def booking_notification(user, booking)
    @user = user
    @booking = booking
    
    mail(
      to: @user.email,
      subject: 'Confirmación de tu reserva en IyaiClub',
      from: email_from(:reservas)
    )
  end

  # Enviar notificaciones de membresía
  def membership_notification(user, action, membership = nil)
    @user = user
    @action = action
    @membership = membership
    
    subject = case action
              when :activada
                '¡Tu membresía IyaiClub está activa!'
              when :renovada
                'Membresía renovada exitosamente'
              when :cancelada
                'Cancelación de membresía'
              else
                'Notificación de membresía'
              end
    
    mail(
      to: @user.email,
      subject: subject,
      from: email_from(:portal)
    )
  end

  private

  # Método helper para diferentes remitentes
  def email_from(type)
    addresses = {
      info: 'IyaiClub <info@iyaiclub.com>',
      reservas: 'IyaiClub Reservas <reservas@iyaiclub.com>',
      soporte: 'IyaiClub Soporte <pauliyai@iyaiclub.com>',
      portal: 'IyaiClub Portal <portal@iyaiclub.com>',
      noreply: 'IyaiClub <noreply@iyaiclub.com>'
    }
    addresses[type] || addresses[:info]
  end
end
