require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class PerfilController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /perfil/:id
  get '/perfil/:id' do
    begin
      id = params['id']

      # Validar que se haya enviado un ID
      if id.nil? || id.strip.empty?
        halt 400, { status: 'error', message: 'Debe proporcionar un ID de usuario' }.to_json
      end

      # Buscar usuario por ID
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

    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json

    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
