# controllers/monedas_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../helpers/generic_response'

class MonedasController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /monedas - Listar todas las monedas
  get '/monedas' do
    begin
      query = "SELECT id, code, nombre FROM Moneda ORDER BY code"
      monedas = DB.execute(query)
      
      generic_response(true, 'Monedas obtenidas correctamente', monedas)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # GET /monedas/:code - Obtener una moneda por código
  get '/monedas/:code' do
    begin
      code = params['code']
      query = "SELECT id, code, nombre FROM Moneda WHERE code = ? LIMIT 1"
      moneda = DB.execute(query, [code]).first

      if moneda
        generic_response(true, 'Moneda encontrada', moneda)
      else
        generic_response(false, 'Moneda no encontrada', nil, nil, 404)
      end
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
