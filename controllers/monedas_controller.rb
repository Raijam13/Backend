require 'sinatra/base'
require 'json'
require_relative '../database'

class MonedasController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /monedas - Listar todas las monedas
  get '/monedas' do
    begin
      query = "SELECT id, code, nombre FROM Moneda ORDER BY code"
      monedas = DB.execute(query)
      
      status 200
      monedas.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # GET /monedas/:code - Obtener una moneda por código
  get '/monedas/:code' do
    begin
      code = params['code']
      query = "SELECT id, code, nombre FROM Moneda WHERE code = ? LIMIT 1"
      moneda = DB.execute(query, [code]).first

      if moneda
        status 200
        moneda.to_json
      else
        halt 404, { status: 'error', message: 'Moneda no encontrada' }.to_json
      end
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
