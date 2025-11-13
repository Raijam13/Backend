require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class EliminarController < Sinatra::Base
  before do
    content_type :json
  end

  delete '/cuenta/:id' do
    begin
      id = params['id']
      payload = request.body.read
      confirm_password = nil

      # Si el cuerpo del request tiene confirmación de contraseña
      unless payload.nil? || payload.strip.empty?
        confirm_password = JSON.parse(payload)['confirm_password']
      end

      usuario = Usuario.find_by_id(id)
      unless usuario
        halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json
      end

      # Validar contraseña si se envía
      if confirm_password
        unless usuario['contraseña'] == confirm_password
          halt 401, { status: 'error', message: 'Contraseña incorrecta' }.to_json
        end
        Usuario.delete_by_id_and_password(id, confirm_password)
      else
        Usuario.delete_by_id(id)
      end

      status 200
      {
        status: 'ok',
        message: 'Cuenta eliminada correctamente'
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
