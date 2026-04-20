module VendedorCodeLookup
  extend ActiveSupport::Concern

  private

  # Busca al vendedor por su código único.
  # Si se pasa `event`, verifica que el vendedor esté asignado y activo en ese evento.
  # Retorna el User o nil.
  def resolve_vendedor_by_code(code, event = nil)
    return nil if code.blank?

    user = User.find_by(vendor_code: code.to_s.strip.upcase, role: :vendedor)
    return nil unless user
    return nil if event && event.active_vendedores.exclude?(user)

    user
  end

  # Devuelve un mensaje de error descriptivo dependiendo del motivo del fallo.
  def vendedor_code_error(code, event = nil)
    user = User.find_by(vendor_code: code.to_s.strip.upcase, role: :vendedor)
    return "Código de vendedor inválido. Verifica el código e inténtalo nuevamente." unless user

    if event && event.active_vendedores.exclude?(user)
      return "El vendedor con ese código no está asignado a este evento. " \
             "Consulta con el organizador."
    end

    "Código de vendedor inválido."
  end
end
