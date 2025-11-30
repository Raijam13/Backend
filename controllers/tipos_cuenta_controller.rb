require 'sinatra/base'
require 'json'
require_relative '../database'

class TiposCuentaController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /tipos-cuenta - Listar todos los tipos de cuenta
  get '/tipos-cuenta' do
    begin
      query = "SELECT id, nombre FROM TipoCuenta ORDER BY nombre"
      tipos = DB.execute(query)
      
      status 200
      tipos.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
