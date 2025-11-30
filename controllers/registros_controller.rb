require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../models/registro'
require_relative '../models/cuenta'
require_relative '../helpers/generic_response'

class RegistrosController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /registros?user_id=:id&limit=20&offset=0
  get '/registros' do
    begin
      user_id = params['user_id']
      limit = params['limit'] || 20
      offset = params['offset'] || 0

      if user_id.nil? || user_id.strip.empty?
        return generic_response(false, 'El parámetro user_id es obligatorio', nil, nil, 400)
      end

      registros = Registro.find_by_user(user_id, limit.to_i, offset.to_i)

      # Formatear respuesta
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

      generic_response(true, 'Registros obtenidos correctamente', resultado)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # GET /registros/:id
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
          idTipoTransaccion: registro['idTipoTransaccion'],
          idUsuario: registro['idUsuario']
        }
        generic_response(true, 'Registro obtenido correctamente', resultado)
      else
        generic_response(false, 'Registro no encontrado', nil, nil, 404)
      end
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # POST /registros
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
        return generic_response(false, 'Todos los campos son obligatorios (idUsuario, idCuenta, idCategoria, idTipoTransaccion, monto)', nil, nil, 400)
      end

      # Verificar que la cuenta existe y pertenece al usuario
      cuenta = Cuenta.find_by_id(id_cuenta)
      unless cuenta
        return generic_response(false, 'Cuenta no encontrada', nil, nil, 404)
      end

      if cuenta['idUsuario'].to_i != id_usuario.to_i
        return generic_response(false, 'La cuenta no pertenece al usuario', nil, nil, 403)
      end

      # Obtener tipo de transacción (gasto/ingreso)
      tipo_nombre = Registro.get_tipo_transaccion(id_tipo_transaccion)
      unless tipo_nombre
        return generic_response(false, 'Tipo de transacción no válido', nil, nil, 400)
      end

      # Transacción DB
      DB.transaction do
        # 1. Insertar registro
        id_registro = Registro.create(fecha_hora, monto, id_cuenta, id_usuario, id_tipo_transaccion, id_categoria)

        # 2. Actualizar saldo
        saldo_actual = cuenta['saldo'].to_f
        if tipo_nombre.downcase == 'ingreso'
          nuevo_saldo = saldo_actual + monto.to_f
        else
          nuevo_saldo = saldo_actual - monto.to_f
        end
        Cuenta.update_saldo(id_cuenta, nuevo_saldo)

        data = {
          id: id_registro,
          monto: monto,
          tipo: tipo_nombre,
          cuenta: cuenta['nombre'],
          nuevo_saldo: nuevo_saldo
        }
        
        generic_response(true, 'Registro creado exitosamente', data, nil, 201)
      end

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # DELETE /registros/:id
  delete '/registros/:id' do
    begin
      id = params['id']
      user_id = params['user_id'] # Para validación de seguridad

      registro = Registro.find_by_id(id)
      unless registro
        return generic_response(false, 'Registro no encontrado', nil, nil, 404)
      end

      # Validar propiedad
      if user_id && registro['idUsuario'].to_s != user_id.to_s
        return generic_response(false, 'No tienes permiso para eliminar este registro', nil, nil, 403)
      end

      id_cuenta = registro['idCuenta']
      monto = registro['monto'].to_f
      tipo_nombre = registro['tipo']

      cuenta = Cuenta.find_by_id(id_cuenta)
      unless cuenta
        return generic_response(false, 'Cuenta asociada no encontrada', nil, nil, 404)
      end

      DB.transaction do
        # 1. Eliminar registro
        Registro.delete_by_id(id)

        # 2. Revertir saldo
        saldo_actual = cuenta['saldo'].to_f
        if tipo_nombre.downcase == 'ingreso'
          nuevo_saldo = saldo_actual - monto
        else
          nuevo_saldo = saldo_actual + monto
        end
        Cuenta.update_saldo(id_cuenta, nuevo_saldo)

        generic_response(true, 'Registro eliminado correctamente', { nuevo_saldo: nuevo_saldo })
      end

    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
