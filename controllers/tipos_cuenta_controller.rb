# controllers/tipos_cuenta_controller.rb

require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../helpers/generic_response'

class TiposCuentaController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /tipos-cuenta - Listar todos los tipos de cuenta
  get '/tipos-cuenta' do
    begin
      query = "SELECT id, nombre FROM TipoCuenta ORDER BY nombre"
      tipos = DB.execute(query)
      
      generic_response(true, 'Tipos de cuenta obtenidos correctamente', tipos)
    rescue SQLite3::Exception => e
      generic_response(false, 'Error en la base de datos', nil, e.message, 500)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
