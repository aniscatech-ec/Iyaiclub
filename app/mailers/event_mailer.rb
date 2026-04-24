class EventMailer < ApplicationMailer
  def event_announcement(user, event)
    @user  = user
    @event = event

    mail(
      to:      user.email,
      subject: "🎉 Nuevo evento: #{event.name} — ¡Compra tu ticket ahora!"
    )
  end
end
