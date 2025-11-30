# controllers/perfil_controller.rb

require 'sinatra/base'
require 'json'
require 'fileutils'
require_relative '../models/usuario'
require_relative '../helpers/generic_response'

class PerfilController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # ---------------------------------------------------------
  # GET: Obtener perfil por ID
  # ---------------------------------------------------------
  get '/perfil/:id' do
    begin
      id = params['id']
      usuario = Usuario.find_by_id(id)

      if usuario
        data = {
          usuario: {
            id: usuario['id'],
            nombres: usuario['nombres'],
            apellidos: usuario['apellidos'],
            correo: usuario['correo'],
            imagen_perfil: usuario['imagen_perfil'],
            fecha_nacimiento: usuario['fecha_nacimiento'],
            genero: usuario['genero']
          }
        }
        generic_response(true, 'Perfil obtenido correctamente', data)
      else
        generic_response(false, 'Usuario no encontrado', nil, nil, 404)
      end
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
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
      unless usuario
        return generic_response(false, 'Usuario no encontrado', nil, nil, 404)
      end

      # Campos permitidos para actualizar
      campos_permitidos = %w[nombres apellidos correo contraseña fecha_nacimiento genero]
      data_actualizar = payload.select { |k, _| campos_permitidos.include?(k) }

      if data_actualizar.empty?
        return generic_response(false, 'No se enviaron campos válidos para actualizar', nil, nil, 400)
      end

      Usuario.update_partial(id, data_actualizar)

      usuario_actualizado = Usuario.find_by_id(id)
      data = {
        usuario: {
          id: usuario_actualizado['id'],
          nombres: usuario_actualizado['nombres'],
          apellidos: usuario_actualizado['apellidos'],
          correo: usuario_actualizado['correo'],
          imagen_perfil: usuario_actualizado['imagen_perfil'],
          fecha_nacimiento: usuario_actualizado['fecha_nacimiento'],
          genero: usuario_actualizado['genero']
        }
      }
      
      generic_response(true, 'Perfil actualizado correctamente', data)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # ---------------------------------------------------------
  # PUT: Actualizar imagen de perfil
  # ---------------------------------------------------------
  put '/perfil/:id/imagen' do
    begin
      id = params['id']
      usuario = Usuario.find_by_id(id)
      unless usuario
        return generic_response(false, 'Usuario no encontrado', nil, nil, 404)
      end

      if params[:imagen].nil?
        return generic_response(false, 'No se envió ninguna imagen', nil, nil, 400)
      end

      imagen = params[:imagen][:tempfile]
      nombre_archivo = params[:imagen][:filename]

      # Crear directorio si no existe
      FileUtils.mkdir_p('public/uploads')

      # Generar nombre único
      ruta_archivo = "public/uploads/#{Time.now.to_i}_#{nombre_archivo}"
      
      # Guardar archivo
      File.open(ruta_archivo, 'wb') { |f| f.write(imagen.read) }

      # Actualizar BD
      url_imagen = "/uploads/#{File.basename(ruta_archivo)}"
      Usuario.update_imagen_perfil(id, url_imagen)

      data = {
        imagen_url: url_imagen
      }

      generic_response(true, 'Imagen de perfil actualizada correctamente', data)

    rescue => e
      generic_response(false, 'Error al subir imagen', nil, e.message, 500)
    end
  end
end
