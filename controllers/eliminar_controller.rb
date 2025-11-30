# controllers/eliminar_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class EliminarController < Sinatra::Base
  helpers GenericResponse

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
        begin
          confirm_password = JSON.parse(payload)['confirm_password']
        rescue JSON::ParserError
          # Si el payload no es JSON válido pero no está vacío, ignoramos o lanzamos error.
          # En este caso, si hay payload esperamos que sea JSON.
          return generic_response(false, 'Formato JSON inválido', nil, nil, 400)
        end
      end

      usuario = Usuario.find_by_id(id)
      unless usuario
        return generic_response(false, 'Usuario no encontrado', nil, nil, 404)
      end

      # Validar contraseña si se envía
      if confirm_password
        unless usuario['contraseña'] == confirm_password
          return generic_response(false, 'Contraseña incorrecta', nil, nil, 401)
        end
        Usuario.delete_by_id_and_password(id, confirm_password)
      else
        Usuario.delete_by_id(id)
      end

      generic_response(true, 'Cuenta eliminada correctamente')

    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
