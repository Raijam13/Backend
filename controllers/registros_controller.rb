require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../models/registro'
require_relative '../models/cuenta'

class RegistrosController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /registros?user_id=:id&limit=20&offset=0 - Listar registros de un usuario
  get '/registros' do
    begin
      user_id = params['user_id']
      limit = params['limit'] || 20
      offset = params['offset'] || 0

      if user_id.nil? || user_id.strip.empty?
        halt 400, { status: 'error', message: 'El parámetro user_id es obligatorio' }.to_json
      end

      registros = Registro.find_by_user(user_id, limit.to_i, offset.to_i)

      # Formatear para el front
      resultado = registros.map do |r|
        fecha = r['fechaHora'].split(' ')[0] rescue r['fechaHora']
        {
          id: r['id'],
          date: fecha,
          dateTime: r['fechaHora'],
          amount: r['monto'],
          type: r['tipo'],
          category: r['categoria'],
          account: r['cuenta'],
          subtitle: "#{r['categoria']} • #{r['cuenta']}"
        }
      end

      status 200
      resultado.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # GET /registros/:id - Obtener detalle de un registro
  get '/registros/:id' do
    begin
      id = params['id']
      registro = Registro.find_by_id(id)

      if registro
        fecha = registro['fechaHora'].split(' ')[0] rescue registro['fechaHora']
        resultado = {
          id: registro['id'],
          date: fecha,
          dateTime: registro['fechaHora'],
          amount: registro['monto'],
          type: registro['tipo'],
          category: registro['categoria'],
          account: registro['cuenta'],
          idCuenta: registro['idCuenta'],
          idCategoria: registro['idCategoria'],
          idTipoTransaccion: registro['idTipoTransaccion']
        }
        status 200
        resultado.to_json
      else
        halt 404, { status: 'error', message: 'Registro no encontrado' }.to_json
      end
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # POST /registros - Crear un nuevo registro (con actualización de saldo)
  post '/registros' do
    begin
      payload = JSON.parse(request.body.read)
      
      id_usuario = payload['idUsuario']
      id_cuenta = payload['idCuenta']
      id_categoria = payload['idCategoria']
      id_tipo_transaccion = payload['idTipoTransaccion']
      monto = payload['monto']
      fecha_hora = payload['fechaHora'] || Time.now.strftime('%Y-%m-%d %H:%M:%S')

      # Validar campos obligatorios
      if [id_usuario, id_cuenta, id_categoria, id_tipo_transaccion, monto].any?(&:nil?)
        halt 400, { status: 'error', message: 'Todos los campos son obligatorios' }.to_json
      end

      # Verificar que la cuenta existe
      cuenta = Cuenta.find_by_id(id_cuenta)
      unless cuenta
        halt 404, { status: 'error', message: 'Cuenta no encontrada' }.to_json
      end

      # Obtener tipo de transacción (gasto/ingreso)
      tipo_nombre = Registro.get_tipo_transaccion(id_tipo_transaccion)
      unless tipo_nombre
        halt 400, { status: 'error', message: 'Tipo de transacción no válido' }.to_json
      end

      # Usar transacción para asegurar consistencia
      DB.transaction do
        # 1. Insertar el registro
        id_registro = Registro.create(fecha_hora, monto, id_cuenta, id_usuario, id_tipo_transaccion, id_categoria)

        # 2. Actualizar saldo de la cuenta
        saldo_actual = cuenta['saldo'].to_f
        if tipo_nombre == 'ingreso'
          nuevo_saldo = saldo_actual + monto.to_f
        else
          nuevo_saldo = saldo_actual - monto.to_f
        end
        Cuenta.update_saldo(id_cuenta, nuevo_saldo)

        status 201
        {
          status: 'ok',
          message: 'Registro creado exitosamente',
          registro: {
            id: id_registro,
            monto: monto,
            tipo: tipo_nombre,
            cuenta: cuenta['nombre'],
            nuevo_saldo: nuevo_saldo
          }
        }.to_json
      end
    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # DELETE /registros/:id - Eliminar un registro (con ajuste de saldo)
  delete '/registros/:id' do
    begin
      id = params['id']

      # Obtener el registro antes de eliminarlo
      registro = Registro.find_by_id(id)
      unless registro
        halt 404, { status: 'error', message: 'Registro no encontrado' }.to_json
      end

      id_cuenta = registro['idCuenta']
      monto = registro['monto'].to_f
      tipo_nombre = registro['tipo']

      # Obtener cuenta
      cuenta = Cuenta.find_by_id(id_cuenta)
      unless cuenta
        halt 404, { status: 'error', message: 'Cuenta asociada no encontrada' }.to_json
      end

      # Usar transacción
      DB.transaction do
        # 1. Eliminar el registro
        Registro.delete_by_id(id)

        # 2. Revertir el saldo (operación contraria)
        saldo_actual = cuenta['saldo'].to_f
        if tipo_nombre == 'ingreso'
          nuevo_saldo = saldo_actual - monto
        else
          nuevo_saldo = saldo_actual + monto
        end
        Cuenta.update_saldo(id_cuenta, nuevo_saldo)

        status 200
        {
          status: 'ok',
          message: 'Registro eliminado correctamente',
          nuevo_saldo: nuevo_saldo
        }.to_json
      end
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
