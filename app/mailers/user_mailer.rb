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
                'Has cancelado tu membresía IyaiClub'
              else
                'Notificación de membresía'
              end

    mail(
      to: @user.email,
      subject: subject,
      from: email_from(:portal)
    )
  end

  # Alerta de membresía próxima a vencer (7 días o 3 días antes)
  def membership_expiry_warning(user, membership, days_left:)
    @user = user
    @membership = membership
    @days_left = days_left

    mail(
      to: @user.email,
      subject: "Tu membresía IyaiClub vence en #{days_left} días",
      from: email_from(:portal)
    )
  end

  # Notificación de inicio de prórroga por impago (5 días extra)
  def membership_grace_period_started(user, membership)
    @user = user
    @membership = membership
    @grace_until = membership.grace_period_until

    mail(
      to: @user.email,
      subject: "Prórroga de 5 días activada en tu membresía IyaiClub",
      from: email_from(:portal)
    )
  end

  # Notificación al admin cuando un cliente no renueva (o cuando expira la prórroga)
  def membership_unpaid_admin_notification(user, membership, grace_ended: false)
    @user = user
    @membership = membership
    @grace_ended = grace_ended

    subject = grace_ended \
      ? "⚠️ Membresía expirada sin pago: #{user.email}"
      : "⚠️ Cliente sin renovación: #{user.email} – prórroga iniciada"

    admin_email = User.where(role: :administrador).pluck(:email).presence || ["pauliyai@iyaiclub.com"]

    mail(
      to: admin_email,
      subject: subject,
      from: email_from(:portal)
    )
  end

  # Notificación al usuario cuando su prórroga termina y la membresía expira
  def membership_expired(user, membership)
    @user = user
    @membership = membership

    mail(
      to: @user.email,
      subject: "Tu membresía IyaiClub ha expirado",
      from: email_from(:portal)
    )
  end

  # Confirmación al usuario cuando solicita un beneficio exclusivo
  def benefit_request_confirmation(user, booking)
    @user    = user
    @booking = booking

    mail(
      to: @user.email,
      subject: "Solicitud de beneficio exclusivo recibida - IyaiClub",
      from: email_from(:reservas)
    )
  end

  # Notificación al admin cuando un usuario solicita un beneficio exclusivo
  def benefit_request_admin_notification(user, booking)
    @user    = user
    @booking = booking

    admin_email = User.where(role: :administrador).pluck(:email).presence || ["pauliyai@iyaiclub.com"]

    mail(
      to: admin_email,
      subject: "🎁 Nueva solicitud de beneficio: #{user.name} – #{booking.benefit_label}",
      from: email_from(:portal)
    )
  end

  # Notificación al usuario cuando el admin activa su beneficio
  def benefit_activated(user, booking)
    @user    = user
    @booking = booking

    mail(
      to: @user.email,
      subject: "¡Tu #{booking.benefit_label} está confirmado! - IyaiClub",
      from: email_from(:reservas)
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
