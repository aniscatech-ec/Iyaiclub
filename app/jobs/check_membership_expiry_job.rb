class CheckMembershipExpiryJob < ApplicationJob
  queue_as :default

  ADMIN_EMAIL = "pauliyai@iyaiclub.com".freeze

  def perform
    check_expiring_soon
    check_expired_memberships
    check_grace_period_ended
  end

  private

  # Alerta 7 días antes de vencer (solo membresías sin cancelación voluntaria ni prórroga activa)
  def check_expiring_soon
    expiring = Subscription
      .where(status: :activada)
      .where(cancelled_at: nil)
      .where("end_date = ?", Date.current + 7.days)

    expiring.each do |sub|
      next unless sub.subscribable_type == "User"
      user = sub.subscribable
      UserMailer.membership_expiry_warning(user, sub, days_left: 7).deliver_later
    end

    # Segunda alerta: 3 días antes
    expiring_soon = Subscription
      .where(status: :activada)
      .where(cancelled_at: nil)
      .where("end_date = ?", Date.current + 3.days)

    expiring_soon.each do |sub|
      next unless sub.subscribable_type == "User"
      user = sub.subscribable
      UserMailer.membership_expiry_warning(user, sub, days_left: 3).deliver_later
    end
  end

  # Membresías que vencieron hoy: iniciar prórroga de 5 días si no fue cancelada por usuario
  def check_expired_memberships
    expired_today = Subscription
      .where(status: :activada)
      .where("end_date < ?", Date.current)

    expired_today.each do |sub|
      next unless sub.subscribable_type == "User"
      user = sub.subscribable

      if sub.cancelled_at.present? && sub.por_usuario?
        # Cancelación voluntaria: simplemente expirar (ya no tiene beneficios)
        sub.expire!
      else
        # No renovó: iniciar prórroga de 5 días
        sub.start_grace_period!

        UserMailer.membership_grace_period_started(user, sub).deliver_later
        UserMailer.membership_unpaid_admin_notification(user, sub).deliver_later
      end
    end
  end

  # Membresías cuya prórroga terminó hoy: expirar definitivamente y notificar
  def check_grace_period_ended
    grace_ended = Subscription
      .where(status: :activada)
      .where(cancellation_type: :por_impago)
      .where("grace_period_until < ?", Date.current)

    grace_ended.each do |sub|
      next unless sub.subscribable_type == "User"
      user = sub.subscribable

      sub.expire!

      UserMailer.membership_expired(user, sub).deliver_later
      UserMailer.membership_unpaid_admin_notification(user, sub, grace_ended: true).deliver_later
    end
  end
end
