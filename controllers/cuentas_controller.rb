require 'sinatra/base'
require 'json'
require_relative '../database'
require_relative '../models/cuenta'
require_relative '../helpers/generic_response'

class CuentasController < Sinatra::Base
  helpers GenericResponse

  before do
    content_type :json
  end

  # GET /cuentas?user_id=:id
  get '/cuentas' do
    begin
      user_id = params['user_id']
      
      if user_id.nil? || user_id.strip.empty?
        return generic_response(false, 'El parámetro user_id es obligatorio', nil, nil, 400)
      end

      cuentas = Cuenta.find_by_user(user_id)
      
      # Mapeo para mantener compatibilidad con el frontend actual si es necesario,
      # pero estandarizando la respuesta envolvente.
      resultado = cuentas.map do |c|
        {
          id: c['id'],
          name: c['nombre'],
          amount: c['saldo'],
          currency: c['moneda_code'] || 'PEN',
          type: c['tipo_cuenta']
        }
      end

      generic_response(true, "Cuentas obtenidas correctamente", resultado)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # GET /cuentas/:id
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
        generic_response(true, "Cuenta obtenida correctamente", resultado)
      else
        generic_response(false, 'Cuenta no encontrada', nil, nil, 404)
      end
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # POST /cuentas
  post '/cuentas' do
    begin
      payload = JSON.parse(request.body.read)
      nombre = payload['nombre']
      saldo = payload['saldo'] || 0.0
      id_usuario = payload['idUsuario']
      code_moneda = payload['codeMoneda'] || 'PEN'
      nombre_tipo = payload['tipoCuenta'] || 'General'

      if nombre.nil? || nombre.strip.empty? || id_usuario.nil?
        return generic_response(false, 'nombre e idUsuario son obligatorios', nil, nil, 400)
      end

      # Validaciones usando SQL directo (idealmente mover a Modelo o Servicio)
      # Por ahora mantenemos la lógica aquí pero usando GenericResponse
      
      query_moneda = "SELECT id FROM Moneda WHERE code = ? OR nombre = ? LIMIT 1"
      moneda = DB.execute(query_moneda, [code_moneda, code_moneda]).first
      unless moneda
        return generic_response(false, "Moneda #{code_moneda} no encontrada", nil, nil, 400)
      end
      id_moneda = moneda['id']

      query_tipo = "SELECT id FROM TipoCuenta WHERE nombre = ? LIMIT 1"
      tipo = DB.execute(query_tipo, [nombre_tipo]).first
      unless tipo
        return generic_response(false, "Tipo de cuenta #{nombre_tipo} no encontrado", nil, nil, 400)
      end
      id_tipo_cuenta = tipo['id']

      id = Cuenta.create(nombre, saldo, id_usuario, id_moneda, id_tipo_cuenta)

      data = {
        id: id,
        name: nombre,
        amount: saldo,
        currency: code_moneda,
        type: nombre_tipo
      }
      
      generic_response(true, 'Cuenta creada exitosamente', data, nil, 201)

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # PUT /cuentas/:id
  put '/cuentas/:id' do
    begin
      id = params['id']
      payload = JSON.parse(request.body.read)
      
      # Validar propiedad si se envía idUsuario (Recomendado)
      id_usuario_request = payload['idUsuario']

      cuenta = Cuenta.find_by_id(id)
      unless cuenta
        return generic_response(false, 'Cuenta no encontrada', nil, nil, 404)
      end

      if id_usuario_request && cuenta['idUsuario'] != id_usuario_request
         return generic_response(false, 'No tienes permiso para editar esta cuenta', nil, nil, 403)
      end

      nombre = payload['nombre'] || cuenta['nombre']
      saldo = payload['saldo'] || cuenta['saldo']
      nombre_tipo = payload['tipoCuenta']

      if nombre_tipo
        query_tipo = "SELECT id FROM TipoCuenta WHERE nombre = ? LIMIT 1"
        tipo = DB.execute(query_tipo, [nombre_tipo]).first
        unless tipo
          return generic_response(false, "Tipo de cuenta #{nombre_tipo} no encontrado", nil, nil, 400)
        end
        id_tipo_cuenta = tipo['id']
      else
        # Si no se envía tipo, mantenemos el actual (que no tenemos en 'cuenta' hash directo, necesitamos query o lógica)
        # El modelo update requiere id_tipo_cuenta.
        # Recuperamos el idTipoCuenta actual
        query = "SELECT idTipoCuenta FROM Cuenta WHERE id = ? LIMIT 1"
        result = DB.execute(query, [id]).first
        id_tipo_cuenta = result['idTipoCuenta']
      end

      # Usamos update simple ya que verificamos propiedad arriba (si se envió idUsuario)
      Cuenta.update(id, nombre, saldo, id_tipo_cuenta)

      generic_response(true, 'Cuenta actualizada exitosamente', { id: id })

    rescue JSON::ParserError
      generic_response(false, 'Formato JSON inválido', nil, nil, 400)
    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end

  # DELETE /cuentas/:id
  delete '/cuentas/:id' do
    begin
      id = params['id']
      user_id = params['user_id'] # Para validación de seguridad

      cuenta = Cuenta.find_by_id(id)
      unless cuenta
        return generic_response(false, 'Cuenta no encontrada', nil, nil, 404)
      end

      if user_id && cuenta['idUsuario'].to_s != user_id.to_s
        return generic_response(false, 'No tienes permiso para eliminar esta cuenta', nil, nil, 403)
      end

      # Verificar registros asociados
      query_registros = "SELECT COUNT(*) as count FROM Registro WHERE idCuenta = ?"
      result = DB.execute(query_registros, [id]).first
      if result['count'] > 0
        return generic_response(false, 'No se puede eliminar la cuenta porque tiene registros asociados', nil, nil, 400)
      end

      Cuenta.delete_by_id(id)

      generic_response(true, 'Cuenta eliminada correctamente', { id: id })

    rescue => e
      generic_response(false, 'Error interno del servidor', nil, e.message, 500)
    end
  end
end
