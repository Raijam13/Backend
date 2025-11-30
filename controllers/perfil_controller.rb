# controllers/perfil_controller.rb

require 'sinatra/base'
require 'json'
require 'fileutils'
require_relative '../models/usuario'

class PerfilController < Sinatra::Base
  before do
    content_type :json
  end

  # ---------------------------------------------------------
  # GET: Obtener perfil por ID
  # ---------------------------------------------------------
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
          correo: usuario['correo'],
          imagen_perfil: usuario['imagen_perfil'],
          fecha_nacimiento: usuario['fecha_nacimiento'],
          genero: usuario['genero']
        }
      }.to_json
    else
      halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json
    end
  end

  # ---------------------------------------------------------
  # PUT: Actualizar perfil parcial
  # ---------------------------------------------------------
  put '/perfil/:id' do
    begin
      id = params['id']
      payload = JSON.parse(request.body.read)

      usuario = Usuario.find_by_id(id)
      halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json unless usuario

      # Campos permitidos para actualizar
      campos_permitidos = %w[nombres apellidos correo contraseña fecha_nacimiento genero]
      data_actualizar = payload.select { |k, _| campos_permitidos.include?(k) }

      if data_actualizar.empty?
        halt 400, { status: 'error', message: 'No se enviaron campos válidos para actualizar' }.to_json
      end

      Usuario.update_partial(id, data_actualizar)

      usuario_actualizado = Usuario.find_by_id(id)
      status 200
      {
        status: 'ok',
        message: 'Perfil actualizado correctamente',
        usuario: {
          id: usuario_actualizado['id'],
          nombres: usuario_actualizado['nombres'],
          apellidos: usuario_actualizado['apellidos'],
          correo: usuario_actualizado['correo'],
          imagen_perfil: usuario_actualizado['imagen_perfil'],
          fecha_nacimiento: usuario_actualizado['fecha_nacimiento'],
          genero: usuario_actualizado['genero']
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

  # ---------------------------------------------------------
  # PUT: Actualizar imagen de perfil
  # ---------------------------------------------------------
  put '/perfil/:id/imagen' do
    begin
      id = params['id']
      usuario = Usuario.find_by_id(id)
      halt 404, { status: 'error', message: 'Usuario no encontrado' }.to_json unless usuario

      if params[:imagen].nil?
        halt 400, { status: 'error', message: 'No se envió ninguna imagen' }.to_json
      end

      imagen = params[:imagen][:tempfile]
      nombre_archivo = params[:imagen][:filename]

      FileUtils.mkdir_p('public/uploads')

      ruta_archivo = "public/uploads/#{Time.now.to_i}_#{nombre_archivo}"
      File.open(ruta_archivo, 'wb') { |f| f.write(imagen.read) }

      url_imagen = "/uploads/#{File.basename(ruta_archivo)}"
      Usuario.update_imagen_perfil(id, url_imagen)

      status 200
      {
        status: 'ok',
        message: 'Imagen de perfil actualizada correctamente',
        imagen_url: url_imagen
      }.to_json

    rescue => e
      halt 500, { status: 'error', message: 'Error al subir imagen', detalle: e.message }.to_json
    end
  end
end
