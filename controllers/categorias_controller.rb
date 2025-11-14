require 'sinatra/base'
require 'json'
require_relative '../database'

class CategoriasController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /categorias - Listar todas las categorías
  get '/categorias' do
    begin
      query = "SELECT id, nombre FROM Categoria ORDER BY nombre"
      categorias = DB.execute(query)
      
      status 200
      categorias.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # GET /categorias/:id - Obtener una categoría por ID
  get '/categorias/:id' do
    begin
      id = params['id']
      query = "SELECT id, nombre FROM Categoria WHERE id = ? LIMIT 1"
      categoria = DB.execute(query, [id]).first

      if categoria
        status 200
        categoria.to_json
      else
        halt 404, { status: 'error', message: 'Categoría no encontrada' }.to_json
      end
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
