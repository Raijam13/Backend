# controllers/categorias_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../helpers/generic_response'

class CategoriasController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /categorias - Listar todas las categorías
  get '/categorias' do
    begin
      query = "SELECT id, nombre FROM Categoria ORDER BY nombre"
      categorias = DB.execute(query)
      
      generic_response(true, 'Categorías obtenidas correctamente', categorias)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # GET /categorias/:id - Obtener una categoría por ID
  get '/categorias/:id' do
    begin
      id = params['id']
      query = "SELECT id, nombre FROM Categoria WHERE id = ? LIMIT 1"
      categoria = DB.execute(query, [id]).first

      if categoria
        generic_response(true, 'Categoría encontrada', categoria)
      else
        generic_response(false, 'Categoría no encontrada', nil, nil, 404)
      end
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
