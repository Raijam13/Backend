# controllers/reset_password_controller.rb

require 'sinatra/base'
require 'json'
require 'securerandom'
require 'net/smtp'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class ResetPasswordController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # POST /reset_password
  post '/reset_password' do
    begin
      payload = JSON.parse(request.body.read)
      correo = payload['correo']

      if correo.nil? || correo.strip.empty?
        return generic_response(false, 'El campo correo es obligatorio', nil, nil, 400)
      end

      usuario = Usuario.find_by_email(correo)
      unless usuario
        return generic_response(false, 'No existe una cuenta con ese correo', nil, nil, 404)
      end

      # 🔑 Generar token temporal (válido por ejemplo 10 minutos)
      token = SecureRandom.hex(16)
      link_ficticio = "https://miapp.com/reset_password?token=#{token}"

      # ✉️ Enviar correo real con SMTP
      begin
        send_reset_email(correo, link_ficticio)
      rescue => e
        return generic_response(false, 'Error al enviar el correo de restablecimiento', nil, e.message, 500)
      end

      data = {
        enlace: link_ficticio
      }

      generic_response(true, "Correo de verificación enviado correctamente a #{correo}.", data)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  private

  # Método que envía el correo real
  def send_reset_email(destinatario, link)
    remitente = "botcorreo2019@gmail.com" || 'miapp@gmail.com'
    contrasena = 'yrlf qmab dboc hflu' || 'contraseña_de_aplicacion'
    asunto = "Restablecimiento de contraseña - MiApp"
    mensaje = <<~EMAIL
      From: MiApp <#{remitente}>
      To: <#{destinatario}>
      Subject: #{asunto}

      Hola,
      Hemos recibido una solicitud para restablecer tu contraseña.
      Para continuar, haz clic en el siguiente enlace:

      #{link}

      Si no realizaste esta solicitud, ignora este mensaje.

      — El equipo de MiApp
    EMAIL

    # Configurar servidor SMTP (ejemplo: Gmail)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', remitente, contrasena, :plain) do |smtp|
      smtp.send_message mensaje, remitente, destinatario
    end
  end
end
