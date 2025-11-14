require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../models/cuenta'

class CuentasController < Sinatra::Base
  before do
    content_type :json
  end

  # GET /cuentas?user_id=:id - Listar cuentas de un usuario
  get '/cuentas' do
    begin
      user_id = params['user_id']
      
      if user_id.nil? || user_id.strip.empty?
        halt 400, { status: 'error', message: 'El parámetro user_id es obligatorio' }.to_json
      end

      cuentas = Cuenta.find_by_user(user_id)
      
      # Formatear respuesta para el front
      resultado = cuentas.map do |c|
        {
          id: c['id'],
          name: c['nombre'],
          amount: c['saldo'],
          currency: c['moneda_code'] || 'PEN',
          type: c['tipo_cuenta']
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

  # GET /cuentas/:id - Obtener detalle de una cuenta
  get '/cuentas/:id' do
    begin
      id = params['id']
      cuenta = Cuenta.find_by_id(id)

      if cuenta
        resultado = {
          id: cuenta['id'],
          name: cuenta['nombre'],
          amount: cuenta['saldo'],
          currency: cuenta['moneda_code'] || 'PEN',
          type: cuenta['tipo_cuenta'],
          idUsuario: cuenta['idUsuario']
        }
        status 200
        resultado.to_json
      else
        halt 404, { status: 'error', message: 'Cuenta no encontrada' }.to_json
      end
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # POST /cuentas - Crear una nueva cuenta
  post '/cuentas' do
    begin
      payload = JSON.parse(request.body.read)
      nombre = payload['nombre']
      saldo = payload['saldo'] || 0.0
      id_usuario = payload['idUsuario']
      code_moneda = payload['codeMoneda'] || 'PEN'
      nombre_tipo = payload['tipoCuenta'] || 'General'

      # Validar campos obligatorios
      if nombre.nil? || nombre.strip.empty? || id_usuario.nil?
        halt 400, { status: 'error', message: 'nombre e idUsuario son obligatorios' }.to_json
      end

      # Obtener id de moneda por code
      query_moneda = "SELECT id FROM Moneda WHERE code = ? OR nombre = ? LIMIT 1"
      moneda = DB.execute(query_moneda, [code_moneda, code_moneda]).first
      unless moneda
        halt 400, { status: 'error', message: "Moneda #{code_moneda} no encontrada" }.to_json
      end
      id_moneda = moneda['id']

      # Obtener id de tipo de cuenta por nombre
      query_tipo = "SELECT id FROM TipoCuenta WHERE nombre = ? LIMIT 1"
      tipo = DB.execute(query_tipo, [nombre_tipo]).first
      unless tipo
        halt 400, { status: 'error', message: "Tipo de cuenta #{nombre_tipo} no encontrado" }.to_json
      end
      id_tipo_cuenta = tipo['id']

      # Crear cuenta
      id = Cuenta.create(nombre, saldo, id_usuario, id_moneda, id_tipo_cuenta)

      status 201
      {
        status: 'ok',
        message: 'Cuenta creada exitosamente',
        cuenta: {
          id: id,
          name: nombre,
          amount: saldo,
          currency: code_moneda,
          type: nombre_tipo
        }
      }.to_json
    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # PUT /cuentas/:id - Actualizar una cuenta
  put '/cuentas/:id' do
    begin
      id = params['id']
      payload = JSON.parse(request.body.read)

      cuenta = Cuenta.find_by_id(id)
      unless cuenta
        halt 404, { status: 'error', message: 'Cuenta no encontrada' }.to_json
      end

      nombre = payload['nombre'] || cuenta['nombre']
      saldo = payload['saldo'] || cuenta['saldo']
      nombre_tipo = payload['tipoCuenta']

      # Obtener id de tipo si se proporcionó
      if nombre_tipo
        query_tipo = "SELECT id FROM TipoCuenta WHERE nombre = ? LIMIT 1"
        tipo = DB.execute(query_tipo, [nombre_tipo]).first
        unless tipo
          halt 400, { status: 'error', message: "Tipo de cuenta #{nombre_tipo} no encontrado" }.to_json
        end
        id_tipo_cuenta = tipo['id']
      else
        # Obtener tipo actual
        query = "SELECT idTipoCuenta FROM Cuenta WHERE id = ? LIMIT 1"
        result = DB.execute(query, [id]).first
        id_tipo_cuenta = result['idTipoCuenta']
      end

      Cuenta.update(id, nombre, saldo, id_tipo_cuenta)

      status 200
      {
        status: 'ok',
        message: 'Cuenta actualizada exitosamente'
      }.to_json
    rescue JSON::ParserError
      halt 400, { status: 'error', message: 'Formato JSON inválido' }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end

  # DELETE /cuentas/:id - Eliminar una cuenta
  delete '/cuentas/:id' do
    begin
      id = params['id']

      cuenta = Cuenta.find_by_id(id)
      unless cuenta
        halt 404, { status: 'error', message: 'Cuenta no encontrada' }.to_json
      end

      # Verificar si tiene registros asociados
      query_registros = "SELECT COUNT(*) as count FROM Registro WHERE idCuenta = ?"
      result = DB.execute(query_registros, [id]).first
      if result['count'] > 0
        halt 400, { status: 'error', message: 'No se puede eliminar la cuenta porque tiene registros asociados' }.to_json
      end

      Cuenta.delete_by_id(id)

      status 200
      {
        status: 'ok',
        message: 'Cuenta eliminada correctamente'
      }.to_json
    rescue SQLite3::Exception => e
      halt 500, { status: 'error', message: 'Error en la base de datos', detalle: e.message }.to_json
    rescue => e
      halt 500, { status: 'error', message: 'Error interno del servidor', detalle: e.message }.to_json
    end
  end
end
