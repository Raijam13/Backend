# controllers/registro_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../models/usuario'

class RegistroController < Sinatra::Base
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
        halt 400, { status: 'error', message: 'Todos los campos son obligatorios' }.to_json
      end

      # Verificar si el correo ya está registrado
      if Usuario.find_by_email(correo)
        halt 409, { status: 'error', message: 'El correo ya está registrado' }.to_json
      end

      # Crear el usuario
      id = Usuario.create(nombres, apellidos, correo, contrasena)

      status 201
      {
        status: 'ok',
        message: 'Usuario creado exitosamente',
        usuario: {
          id: id,
          nombres: nombres,
          apellidos: apellidos,
          correo: correo
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
