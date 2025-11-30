# controllers/two_factor_controller.rb

require 'sinatra/base'
require 'json'
require 'securerandom'
require 'net/smtp'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class TwoFactorController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # POST /two_factor/send_code
  post '/two_factor/send_code' do
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

      # 🔢 Generar un código aleatorio de 6 dígitos
      codigo = rand(100000..999999).to_s

      # ✉️ Enviar el correo
      begin
        send_two_factor_email(correo, codigo)
      rescue => e
        # Si falla el envío de correo, devolvemos error 500 pero con detalle
        return generic_response(false, 'Error al enviar el correo de verificación', nil, e.message, 500)
      end

      data = {
        codigo_fake_para_testing: codigo # <- bórralo cuando termines de testear o en prod
      }

      generic_response(true, "Código de verificación enviado a #{correo}.", data)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  private

  # Método que envía el correo real usando SMTP
  def send_two_factor_email(destinatario, codigo)
    remitente = "botcorreo2019@gmail.com" || 'miapp@gmail.com'
    contrasena = 'yrlf qmab dboc hflu' || 'contraseña_de_aplicacion'
    asunto = "Código de verificación - MiApp"

    mensaje = <<~EMAIL
      From: MiApp <#{remitente}>
      To: <#{destinatario}>
      Subject: #{asunto}

      Hola,
      Tu código de verificación es:

      #{codigo}

      Este código expira en 10 minutos.

      — El equipo de MiApp
    EMAIL

    # Configuración SMTP (Gmail)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', remitente, contrasena, :plain) do |smtp|
      smtp.send_message mensaje, remitente, destinatario
    end
  end
end
