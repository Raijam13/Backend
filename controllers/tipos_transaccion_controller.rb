require 'sinatra/base'
require 'json'
require_relative '../database'

class TiposTransaccionController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /tipos-transaccion - Listar todos los tipos de transacción
  get '/tipos-transaccion' do
    begin
      query = "SELECT id, nombre FROM TipoTransaccion ORDER BY id"
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
