require 'sinatra/base'
require 'json'
require 'securerandom'
require 'net/smtp'
require_relative '../models/usuario'

class ResetPasswordController < Sinatra::Base
  before do
    content_type :json
  endS

  # POST /reset_password
  post '/reset_password' do
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

      # 🔑 Generar token temporal (válido por ejemplo 10 minutos)
      token = SecureRandom.hex(16)
      link_ficticio = "https://miapp.com/reset_password?token=#{token}"

      # ✉️ Enviar correo real con SMTP
      send_reset_email(correo, link_ficticio)

      status 200
      {
        status: 'ok',
        message: "Correo de verificación enviado correctamente a #{correo}.",
        enlace: link_ficticio
      }.to_json

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
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
