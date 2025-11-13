require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class PerfilController < Sinatra::Base
  before do
    content_type :json
  end

  # Obtener perfil por ID
  get '/perfil/:id' do
    id = params['id']
    usuario = Usuario.find_by_id(id)

    if usuario
      status 200
      {
        status: 'ok',
        message: 'Perfil obtenido correctamente',
        usuario: {
          id: usuario['id'],
          nombres: usuario['nombres'],
          apellidos: usuario['apellidos'],
          correo: usuario['correo']
        }
      }.to_json
    else
      halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json
    end
  end

  # Actualizar perfil parcial
  put '/perfil/:id' do
    begin
      id = params['id']
      payload = JSON.parse(request.body.read)

      # Validar si el usuario existe
      usuario = Usuario.find_by_id(id)
      unless usuario
        halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json
      end

      # Filtrar solo los campos permitidos
      campos_permitidos = %w[nombres apellidos correo contraseña]
      data_actualizar = payload.select { |k, _| campos_permitidos.include?(k) }

      if data_actualizar.empty?
        halt 400, { status: 'error', message: 'No se enviaron campos válidos para actualizar' }.to_json
      end

      Usuario.update_partial(id, data_actualizar)

      # Obtener el usuario actualizado
      usuario_actualizado = Usuario.find_by_id(id)

      status 200
      {
        status: 'ok',
        message: 'Perfil actualizado correctamente',
        usuario: {
          id: usuario_actualizado['id'],
          nombres: usuario_actualizado['nombres'],
          apellidos: usuario_actualizado['apellidos'],
          correo: usuario_actualizado['correo']
        }
      }.to_json

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
