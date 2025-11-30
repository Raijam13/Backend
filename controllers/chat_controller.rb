# controllers/chat_controller.rb

require 'sinatra/base'
require 'json'
require 'time'
require_relative '../models/mensaje'
require_relative '../helpers/generic_response'

class ChatController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # Enviar mensaje al chat y obtener respuesta  
  post '/chat' do
    begin
      payload = JSON.parse(request.body.read)
      mensaje_usuario = payload['mensaje']
      id_usuario = payload['idUsuario']

      if mensaje_usuario.nil? || mensaje_usuario.strip.empty?
        return generic_response(false, 'El mensaje no puede estar vacío', nil, nil, 400)
      end

      if id_usuario.nil?
        return generic_response(false, 'El idUsuario es obligatorio', nil, nil, 400)
      end

      # Generar respuesta
      respuesta = generar_respuesta(mensaje_usuario)
      fecha = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      # Guardar mensaje del usuario
      Mensaje.create(id_usuario, "Usuario: #{mensaje_usuario}", fecha)

      # Guardar respuesta del bot
      Mensaje.create(id_usuario, "Bot: #{respuesta}", fecha)

      data = {
        respuesta: respuesta
      }

      generic_response(true, 'Respuesta generada y guardada correctamente', data)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno', nil, e.message, 500)
    end
  end

  # Obtener historial del chat de un usuario
  get '/chat/:id_usuario' do
    begin
      id_usuario = params['id_usuario']
      mensajes = Mensaje.find_by_user(id_usuario)

      if mensajes.empty?
        # Nota: Podríamos devolver 200 con lista vacía, pero el requerimiento original era 404.
        # Para mantener compatibilidad con frontend si espera 404:
        return generic_response(false, 'No hay mensajes para este usuario', [], nil, 404)
      end

      data = {
        historial: mensajes
      }

      generic_response(true, 'Historial obtenido correctamente', data)

    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno', nil, e.message, 500)
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
