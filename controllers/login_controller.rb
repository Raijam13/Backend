# controllers/login_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class LoginController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  post '/login' do
    begin
      payload = JSON.parse(request.body.read)
      correo = payload['correo']
      contraseña = payload['contraseña']

      if correo.nil? || contraseña.nil? || correo.strip.empty? || contraseña.strip.empty?
        return generic_response(false, 'Correo y contraseña son obligatorios', nil, nil, 400)
      end

      usuario = Usuario.find_by_credentials(correo, contraseña)

      if usuario
        data = {
          usuario: {
            id: usuario['id'],
            correo: usuario['correo'],
            nombres: usuario['nombres'],
            apellidos: usuario['apellidos'],
            imagen_perfil: usuario['imagen_perfil']
          }
        }
        generic_response(true, 'Inicio de sesión exitoso', data, nil, 200)
      else
        generic_response(false, 'Correo o contraseña incorrectos', nil, nil, 401)
      end

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido o no ingreso credenciales', nil, nil, 400)

    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
