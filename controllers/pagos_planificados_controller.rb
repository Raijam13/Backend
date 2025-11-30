require 'sinatra/base'
require 'sinatra/json'
require_relative '../models/pago_planificado'
require_relative '../models/catalogos'
require_relative '../helpers/generic_response'

class PagosPlanificadosController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  ############################################
  # 1) GET CATÁLOGOS
  ############################################
  get '/pagos-planificados/catalogos' do
    begin
      user_id = params['user_id']
      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      data = {
        tipos_transaccion: TipoTransaccion.all,
        frecuencias: Frecuencia.all,
        categorias: Categoria.all,
        tipos_pago: TipoPago.all,
        cuentas: Cuenta.find_by_user(user_id)
      }

      generic_response(true, "Catálogos obtenidos correctamente", data)
    rescue => e
      generic_response(false, "Error al obtener catálogos", nil, e.message, 500)
    end
  end

  ############################################
  # 2) LISTAR PAGOS PLANIFICADOS
  ############################################
  get '/pagos-planificados' do
    begin
      user_id = params['user_id']
      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      pagos = PagoPlanificado.all_by_user(user_id)
      
      # Mapeo para asegurar consistencia con el frontend si es necesario
      # El modelo ya devuelve: id, nombre, monto, tipo, periodo, categoria, fechaInicio, intervalo
      
      generic_response(true, "Pagos obtenidos correctamente", pagos)
    rescue => e
      generic_response(false, "Error al listar pagos planificados", nil, e.message, 500)
    end
  end

  ############################################
  # 3) CREAR PAGO PLANIFICADO
  ############################################
  post '/pagos-planificados' do
    begin
      body = JSON.parse(request.body.read)
      
      # Validar campos obligatorios
      required = %w[nombre monto tipo periodo categoria id_cuenta tipo_pago idUsuario]
      missing = required.select { |k| !body.key?(k) || body[k].nil? }

      if !missing.empty?
        return generic_response(false, "Faltan campos obligatorios: #{missing.join(', ')}", nil, nil, 400)
      end

      # Validar existencia de catálogos (Búsqueda por nombre)
      id_frecuencia = Frecuencia.find_id_by_nombre(body["periodo"])
      id_categoria  = Categoria.find_id_by_nombre(body["categoria"])
      id_tipo_trans = TipoTransaccion.find_id_by_nombre(body["tipo"])
      id_tipo_pago  = TipoPago.find_id_by_nombre(body["tipo_pago"])

      unless id_frecuencia && id_categoria && id_tipo_trans && id_tipo_pago
        return generic_response(false, "Datos de catálogo inválidos (periodo, categoria, tipo o tipo_pago incorrectos)", nil, nil, 400)
      end

      # Preparar datos para el modelo
      data = {
        nombre: body["nombre"],
        monto: body["monto"],
        idCuenta: body["id_cuenta"],
        idUsuario: body["idUsuario"],
        idCategoria: id_categoria,
        idTipoTransaccion: id_tipo_trans,
        idFrecuencia: id_frecuencia,
        intervalo: body["intervalo"] || 1,
        fechaInicio: body["fecha_inicio"], # Asegurarse que el front mande fecha_inicio
        idTipoPago: id_tipo_pago
      }

      new_id = PagoPlanificado.create(data)

      generic_response(true, "Pago planificado creado exitosamente", { id: new_id }, nil, 201)

    rescue JSON::ParserError
      generic_response(false, "JSON inválido", nil, nil, 400)
    rescue => e
      generic_response(false, "Error al crear pago planificado", nil, e.message, 500)
    end
  end

  ############################################
  # 4) ACTUALIZAR PAGO PLANIFICADO
  ############################################
  put '/pagos-planificados/:id' do
    begin
      id = params[:id]
      body = JSON.parse(request.body.read)
      
      # Validamos que venga el idUsuario para seguridad básica (o verificación de propiedad)
      if body["idUsuario"].nil?
        return generic_response(false, "El idUsuario es obligatorio para verificar propiedad", nil, nil, 400)
      end

      # Validar existencia de catálogos
      id_frecuencia = Frecuencia.find_id_by_nombre(body["periodo"])
      id_categoria  = Categoria.find_id_by_nombre(body["categoria"])
      id_tipo_trans = TipoTransaccion.find_id_by_nombre(body["tipo"])
      id_tipo_pago  = TipoPago.find_id_by_nombre(body["tipo_pago"])

      unless id_frecuencia && id_categoria && id_tipo_trans && id_tipo_pago
        return generic_response(false, "Datos de catálogo inválidos", nil, nil, 400)
      end

      data = {
        nombre: body["nombre"],
        monto: body["monto"],
        idCuenta: body["id_cuenta"],
        idCategoria: id_categoria,
        idTipoTransaccion: id_tipo_trans,
        idFrecuencia: id_frecuencia,
        intervalo: body["intervalo"] || 1,
        fechaInicio: body["fecha_inicio"],
        idTipoPago: id_tipo_pago
      }

      PagoPlanificado.update(id, body["idUsuario"], data)

      generic_response(true, "Pago planificado actualizado correctamente", { id: id })

    rescue JSON::ParserError
      generic_response(false, "JSON inválido", nil, nil, 400)
    rescue => e
      generic_response(false, "Error al actualizar pago planificado", nil, e.message, 500)
    end
  end

  ############################################
  # 5) ELIMINAR PAGO PLANIFICADO
  ############################################
  delete '/pagos-planificados/:id' do
    begin
      id = params[:id]
      # Necesitamos el user_id para asegurar que borra SU pago. 
      # Lo ideal sería recibirlo por query param o body. 
      # Por consistencia con GET, usaremos query param 'user_id'
      user_id = params['user_id']

      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      PagoPlanificado.delete(id, user_id)

      generic_response(true, "Pago planificado eliminado correctamente", { id: id })
    rescue => e
      generic_response(false, "Error al eliminar pago planificado", nil, e.message, 500)
    end
  end

end
