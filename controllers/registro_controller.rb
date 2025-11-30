# controllers/registro_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class RegistroController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # POST /registro
  post '/registro' do
    begin
      # Leer el JSON recibido
      payload = JSON.parse(request.body.read)
      nombres = payload['nombres']
      apellidos = payload['apellidos']
      correo = payload['correo']
      contrasena = payload['contrasena'] || payload['contraseña']

      # Validar campos obligatorios
      if [nombres, apellidos, correo, contrasena].any? { |campo| campo.nil? || campo.strip.empty? }
        return generic_response(false, 'Todos los campos son obligatorios', nil, nil, 400)
      end

      # Verificar si el correo ya está registrado
      if Usuario.find_by_email(correo)
        return generic_response(false, 'El correo ya está registrado', nil, nil, 409)
      end

      # Crear el usuario
      id = Usuario.create(nombres, apellidos, correo, contrasena)

      data = {
        usuario: {
          id: id,
          nombres: nombres,
          apellidos: apellidos,
          correo: correo
        }
      }

      generic_response(true, 'Usuario creado exitosamente', data, nil, 201)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)

    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
