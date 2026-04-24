class BroadcastEventJob < ApplicationJob
  queue_as :mailers

  # Envía el anuncio del evento a todos los usuarios registrados en lotes
  # para no saturar el servidor de correo ni la memoria.
  BATCH_SIZE = 100

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event

    User.where.not(email: [nil, ""]).in_batches(of: BATCH_SIZE) do |batch|
      batch.each do |user|
        EventMailer.event_announcement(user, event).deliver_later
      end
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("[BroadcastEventJob] Evento #{event_id} no encontrado.")
  end
end
