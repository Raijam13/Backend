# controllers/tipos_transaccion_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../helpers/generic_response'

class TiposTransaccionController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /tipos-transaccion - Listar todos los tipos de transacción
  get '/tipos-transaccion' do
    begin
      query = "SELECT id, nombre FROM TipoTransaccion ORDER BY id"
      tipos = DB.execute(query)
      
      generic_response(true, 'Tipos de transacción obtenidos correctamente', tipos)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
