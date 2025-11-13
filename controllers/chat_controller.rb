require 'sinatra/base'
require 'json'
require 'time'
require_relative '../models/mensaje'

class ChatController < Sinatra::Base
  before do
    content_type :json
  end

  # Enviar mensaje al chat y obtener respuesta  
  post '/chat' do
    begin
      payload = JSON.parse(request.body.read)
      mensaje_usuario = payload['mensaje']
      id_usuario = payload['idUsuario']  # ← ID del usuario que manda el mensaje

      if mensaje_usuario.nil? || mensaje_usuario.strip.empty?
        halt 400, { status: 'error', message: 'El mensaje no puede estar vacío' }.to_json
      end

      # Generar respuesta
      respuesta = generar_respuesta(mensaje_usuario)
      fecha = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      # Guardar mensaje del usuario
      Mensaje.create(id_usuario, "Usuario: #{mensaje_usuario}", fecha)

      # Guardar respuesta del bot
      Mensaje.create(id_usuario, "Bot: #{respuesta}", fecha)

      status 200
      {
        status: 'ok',
        message: 'Respuesta generada y guardada correctamente',
        respuesta: respuesta
      }.to_json

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno', detalle: e.message }.to_json
    end
  end

  # Obtener historial del chat de un usuario
  get '/chat/:id_usuario' do
    begin
      id_usuario = params['id_usuario']
      mensajes = Mensaje.find_by_user(id_usuario)

      if mensajes.empty?
        halt 404, { status: 'error', message: 'No hay mensajes para este usuario' }.to_json
      end

      status 200
      {
        status: 'ok',
        message: 'Historial obtenido correctamente',
        historial: mensajes
      }.to_json

    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    end
  end

  # --- Lógica de respuestas automáticas ---
  def generar_respuesta(texto)
    texto = texto.downcase

    if texto.include?('gasto') && texto.include?('mes')
      return 'Has gastado un 15% más que el mes pasado. Te recomiendo revisar tus compras en entretenimiento.'
    elsif texto.include?('categoría') || texto.include?('gasté más')
      return 'Tu categoría con más gasto este mes es "Comida y restaurantes".'
    elsif texto.include?('mejorar') || texto.include?('finanzas')
      return 'Puedes mejorar tus finanzas personales ahorrando un 10% de tus ingresos cada mes.'
    else
      return 'No tengo una respuesta exacta, pero puedo ayudarte a analizar tus gastos si me das más detalles.'
    end
  end
end
