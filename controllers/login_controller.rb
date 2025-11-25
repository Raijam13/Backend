# controllers/login_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class LoginController < Sinatra::Base
  before do
    content_type :json
  end

  post '/login' do
    begin
      payload = JSON.parse(request.body.read)
      correo = payload['correo']
      contraseña = payload['contraseña']

      if correo.nil? || contraseña.nil? || correo.strip.empty? || contraseña.strip.empty?
        halt 400, { status: 'error', message: 'Correo y contraseña son obligatorios' }.to_json
      end

      usuario = Usuario.find_by_credentials(correo, contraseña)

      if usuario
        status 200
        {
          status: 'ok',
          message: 'Inicio de sesión exitoso',
          usuario: {
            id: usuario['id'],
            correo: usuario['correo'],
            nombres: usuario['nombres'],
            apellidos: usuario['apellidos'],
            imagen_perfil: usuario['imagen_perfil']
          }
        }.to_json
      else
        halt 401, { status: 'error', message: 'Correo o contraseña incorrectos' }.to_json
      end

    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido o no ingreso credenciales' }.to_json

    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json

    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
