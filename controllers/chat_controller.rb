require 'sinatra/base'
require 'json'

class ChatController < Sinatra::Base
  before do
    content_type :json
  end

  post '/chat' do
    begin
      payload = JSON.parse(request.body.read)
      mensaje_usuario = payload['mensaje']

      if mensaje_usuario.nil? || mensaje_usuario.strip.empty?
        halt 400, { status: 'error', message: 'El mensaje no puede estar vacío' }.to_json
      end

      respuesta = generar_respuesta(mensaje_usuario)

      status 200
      {
        status: 'ok',
        message: 'Respuesta generada correctamente',
        respuesta: respuesta
      }.to_json

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno', detalle: e.message }.to_json
    end
  end

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
