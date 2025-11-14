require 'sinatra/base'
require 'sinatra/json'

class PagosPlanificadosController < Sinatra::Base
  before do
    content_type :json
    @id_usuario = 1
  end

  ############################################
  # 1) GET CATÁLOGOS
  ############################################
  get '/pagos-planificados/catalogos' do
    begin
      tipos_trans = DB.execute("SELECT id, nombre FROM TipoTransaccion")
      frecuencias = DB.execute("SELECT id, nombre FROM Frecuencia")
      categorias  = DB.execute("SELECT id, nombre FROM Categoria")
      tipos_pago  = DB.execute("SELECT id, nombre FROM TipoPago")
      cuentas     = DB.execute("SELECT id, nombre, saldo, idMoneda FROM Cuenta WHERE idUsuario = ?", [@id_usuario])

      json({
        success: true,
        message: "Catálogos obtenidos correctamente",
        data: {
          tipos_transaccion: tipos_trans,
          frecuencias: frecuencias,
          categorias: categorias,
          tipos_pago: tipos_pago,
          cuentas: cuentas
        }
      })
    rescue => e
      status 500
      json success: false, message: "Error al obtener catálogos", error: e.message
    end
  end

  ############################################
  # 2) LISTAR PAGOS PLANIFICADOS
  ############################################
  get '/pagos-planificados' do
    begin
      rows = DB.execute(<<~SQL)
        SELECT
          p.id,
          p.nombre,
          p.monto,
          tt.nombre AS tipo,
          f.nombre  AS periodo,
          c.nombre  AS categoria,
          p.fechaInicio AS proximaFecha
        FROM PagoPlanificado p
        JOIN Frecuencia f ON p.idFrecuencia = f.id
        JOIN Categoria  c ON p.idCategoria = c.id
        JOIN TipoTransaccion tt ON p.idTipoTransaccion = tt.id
        WHERE p.idUsuario = #{@id_usuario};
      SQL

      json success: true, message: "Pagos obtenidos", data: rows
    rescue => e
      status 500
      json success: false, message: "Error al listar", error: e.message
    end
  end

  ############################################
  # 3) CREAR PAGO PLANIFICADO
  ############################################
  post '/pagos-planificados' do
    body = JSON.parse(request.body.read) rescue {}

    required = %w[nombre monto tipo periodo categoria id_cuenta tipo_pago]
    missing = required.select { |k| !body.key?(k) }

    if !missing.empty?
      status 400
      return json({ success: false, message: "Faltan campos: #{missing.join(', ')}" })
    end

    begin
      freq = DB.execute("SELECT id FROM Frecuencia WHERE nombre = ?", [body["periodo"]]).first
      cat  = DB.execute("SELECT id FROM Categoria WHERE nombre = ?", [body["categoria"]]).first
      tipo = DB.execute("SELECT id FROM TipoTransaccion WHERE nombre = ?", [body["tipo"]]).first
      tpago = DB.execute("SELECT id FROM TipoPago WHERE nombre = ?", [body["tipo_pago"]]).first

      idFrecuencia = freq&.dig("id")
      idCategoria  = cat&.dig("id")
      idTipoTrans  = tipo&.dig("id")
      idTipoPago   = tpago&.dig("id")

      raise "Frecuencia no válida" unless idFrecuencia
      raise "Categoría no válida"  unless idCategoria
      raise "Tipo transacción no válido" unless idTipoTrans
      raise "Tipo pago no válido" unless idTipoPago

      sql = <<~SQL
        INSERT INTO PagoPlanificado
        (idUsuario, nombre, monto, idTipoTransaccion, idFrecuencia, idCategoria, idTipoPago, idCuenta, fechaInicio, intervalo, finTipo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL

      DB.execute(sql, [
        @id_usuario,
        body["nombre"],
        body["monto"],
        idTipoTrans,
        idFrecuencia,
        idCategoria,
        idTipoPago,
        body["id_cuenta"],
        body["fecha_inicio"],
        body["intervalo"] || 1,
        body["fin_tipo"] || "NUNCA"
      ])

      id = DB.execute("SELECT last_insert_rowid() AS id").first["id"]

      json success: true, message: "Pago creado", data: { id: id }

    rescue => e
      status 500
      json success: false, message: "Error al crear pago", error: e.message
    end
  end

  ############################################
  # 4) ACTUALIZAR
  ############################################
  put '/pagos-planificados/:id' do
    id = params[:id]
    body = JSON.parse(request.body.read) rescue {}

    begin
      existing = DB.execute("SELECT * FROM PagoPlanificado WHERE id = ?", [id])
      if existing.empty?
        status 404
        return json({ success: false, message: "Pago planificado no encontrado" })
      end

      freq = DB.execute("SELECT id FROM Frecuencia WHERE nombre = ?", [body["periodo"]]).first
      cat  = DB.execute("SELECT id FROM Categoria WHERE nombre = ?", [body["categoria"]]).first
      tipo = DB.execute("SELECT id FROM TipoTransaccion WHERE nombre = ?", [body["tipo"]]).first
      tpago = DB.execute("SELECT id FROM TipoPago WHERE nombre = ?", [body["tipo_pago"]]).first

      sql = <<~SQL
        UPDATE PagoPlanificado
        SET nombre = ?, monto = ?, idTipoTransaccion = ?, idFrecuencia = ?, idCategoria = ?, idTipoPago = ?, idCuenta = ?, fechaInicio = ?, intervalo = ?, finTipo = ?
        WHERE id = ?
      SQL

      DB.execute(sql, [
        body["nombre"],
        body["monto"],
        tipo&.dig("id"),
        freq&.dig("id"),
        cat&.dig("id"),
        tpago&.dig("id"),
        body["id_cuenta"],
        body["fecha_inicio"],
        body["intervalo"] || 1,
        body["fin_tipo"] || "NUNCA",
        id
      ])

      json success: true, message: "Pago actualizado", data: { id: id }

    rescue => e
      status 500
      json success: false, message: "Error al actualizar", error: e.message
    end
  end

  delete '/pagos-planificados/:id' do
    id = params[:id]

    begin
        existing = DB.execute("SELECT * FROM PagoPlanificado WHERE id = ?", [id])
        if existing.empty?
        status 404
        return json({ success: false, message: "Pago planificado no encontrado" })
        end

        DB.execute("DELETE FROM PagoPlanificado WHERE id = ?", [id])

        json success: true, message: "Pago planificado eliminado", data: { id: id }

        rescue => e
            status 500
            json success: false, message: "Error al eliminar", error: e.message
        end
    end

end
