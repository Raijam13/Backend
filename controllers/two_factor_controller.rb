# controllers/two_factor_controller.rb

require 'sinatra/base'
require 'json'
require 'securerandom'
require 'net/smtp'
require_relative '../models/usuario'

class TwoFactorController < Sinatra::Base
  before do
    content_type :json
  end

  # POST /two_factor/send_code
  post '/two_factor/send_code' do
    begin
      payload = JSON.parse(request.body.read)
      correo = payload['correo']

      if correo.nil? || correo.strip.empty?
        halt 400, { status: 'error', message: 'El campo correo es obligatorio' }.to_json
      end

      usuario = Usuario.find_by_email(correo)
      unless usuario
        halt 404, { status: 'error', message: 'No existe una cuenta con ese correo' }.to_json
      end

      # 🔢 Generar un código aleatorio de 6 dígitos
      codigo = rand(100000..999999).to_s

      # ✉️ Enviar el correo
      send_two_factor_email(correo, codigo)

      status 200
      {
        status: 'ok',
        message: "Código de verificación enviado a #{correo}.",
        codigo_fake_para_testing: codigo # <- bórralo cuando termines de testear
      }.to_json

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
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
