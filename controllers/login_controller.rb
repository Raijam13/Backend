require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class LoginController < Sinatra::Base
  before do
    content_type :json
  end

  # POST /login
  post '/login' do
    begin
      payload = JSON.parse(request.body.read)
      correo = payload['correo']
      contraseña = payload['contraseña']

      usuario = Usuario.find_by_credentials(correo, contraseña)

      if usuario
        {
          status: 'ok',
          message: 'Inicio de sesión exitoso',
          
        }.to_json
      else
        halt 401, { status: 'error', message: 'Correo o contraseña incorrectos' }.to_json
      end
    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    end
  end
end
