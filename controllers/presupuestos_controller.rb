require 'sinatra/base'
require 'json'
require_relative '../models/presupuesto'
require_relative '../models/catalogos'
require_relative '../helpers/generic_response'

class PresupuestosController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /presupuestos/catalogos
  get '/presupuestos/catalogos' do
    begin
      user_id = params['user_id']
      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      catalogos = {
        categorias: Categoria.all,
        periodos: PeriodoPresupuesto.all,
        cuentas: Cuenta.find_by_user(user_id)
      }

      generic_response(true, "Catálogos obtenidos correctamente", catalogos)
    rescue => e
      generic_response(false, "Error al obtener catálogos", nil, e.message, 500)
    end
  end

  # GET /presupuestos
  get '/presupuestos' do
    begin
      user_id = params['user_id']
      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      presupuestos = Presupuesto.all_by_user(user_id)
      generic_response(true, "Presupuestos obtenidos correctamente", presupuestos)
    rescue => e
      generic_response(false, "Error al listar presupuestos", nil, e.message, 500)
    end
  end

  # GET /presupuestos/:id
  get '/presupuestos/:id' do
    begin
      id = params[:id]
      presupuesto = Presupuesto.find_by_id(id)

      if presupuesto
        generic_response(true, "Presupuesto obtenido correctamente", presupuesto)
      else
        generic_response(false, "Presupuesto no encontrado", nil, nil, 404)
      end
    rescue => e
      generic_response(false, "Error al obtener presupuesto", nil, e.message, 500)
    end
  end

  # POST /presupuestos
  post '/presupuestos' do
    begin
      body = JSON.parse(request.body.read)

      # Validar campos obligatorios
      required = %w[nombre periodo user_id]
      missing = required.select { |k| !body.key?(k) || body[k].nil? }

      # Validar que al menos uno de monto o monto_total esté presente
      if !body["monto"] && !body["monto_total"]
        missing << "monto/monto_total"
      end

      if !missing.empty?
        return generic_response(false, "Faltan campos obligatorios: #{missing.join(', ')}", nil, nil, 400)
      end

      # Validar catálogos
      id_frecuencia = PeriodoPresupuesto.find_id_by_nombre(body["periodo"])
      unless id_frecuencia
        return generic_response(false, "Periodo inválido", nil, nil, 400)
      end

      # Opcionales
      id_categoria = body["id_categoria"]
      id_cuenta = body["id_cuenta"]
      
      # Preparar datos
      data = {
        nombre: body["nombre"],
        monto: body["monto_total"] || body["monto"],
        notificarExceso: body["notificar_exceso"] ? 1 : 0,
        idCuenta: id_cuenta,
        idUsuario: body["user_id"],
        idPeriodoPresupuesto: id_frecuencia,
        idCategoria: id_categoria,
        idTipoTransaccion: nil
      }

      new_id = Presupuesto.create(data)
      generic_response(true, "Presupuesto creado exitosamente", { id: new_id }, nil, 201)

    rescue JSON::ParserError
      generic_response(false, "JSON inválido", nil, nil, 400)
    rescue => e
      generic_response(false, "Error al crear presupuesto", nil, e.message, 500)
    end
  end

  # PUT /presupuestos/:id
  put '/presupuestos/:id' do
    begin
      id = params[:id]
      body = JSON.parse(request.body.read)

      if body["user_id"].nil?
        return generic_response(false, "El user_id es obligatorio", nil, nil, 400)
      end

      # Validar catálogos
      id_frecuencia = PeriodoPresupuesto.find_id_by_nombre(body["periodo"])
      unless id_frecuencia
        return generic_response(false, "Periodo inválido", nil, nil, 400)
      end

      data = {
        nombre: body["nombre"],
        monto: body["monto_total"] || body["monto"],
        notificarExceso: body["notificar_exceso"] ? 1 : 0,
        idCuenta: body["id_cuenta"],
        idPeriodoPresupuesto: id_frecuencia,
        idCategoria: body["id_categoria"],
        idTipoTransaccion: nil
      }

      Presupuesto.update(id, body["user_id"], data)
      generic_response(true, "Presupuesto actualizado correctamente", { id: id })

    rescue JSON::ParserError
      generic_response(false, "JSON inválido", nil, nil, 400)
    rescue => e
      generic_response(false, "Error al actualizar presupuesto", nil, e.message, 500)
    end
  end

  # DELETE /presupuestos/:id
  delete '/presupuestos/:id' do
    begin
      id = params[:id]
      user_id = params['user_id']

      if user_id.nil?
        return generic_response(false, "El parámetro user_id es obligatorio", nil, nil, 400)
      end

      Presupuesto.delete(id, user_id)
      generic_response(true, "Presupuesto eliminado correctamente", { id: id })
    rescue => e
      generic_response(false, "Error al eliminar presupuesto", nil, e.message, 500)
    end
  end
end
