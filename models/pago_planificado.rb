# models/pago_planificado.rb

require_relative '../database'

class PagoPlanificado
  def self.all_by_user(id_usuario)
    query = <<-SQL
      SELECT 
        p.id,
        p.nombre,
        p.monto,
        tt.nombre AS tipo,
        f.nombre AS periodo,
        c.nombre AS categoria,
        p.fechaInicio,
        p.intervalo
      FROM PagoPlanificado p
      JOIN TipoTransaccion tt ON tt.id = p.idTipoTransaccion
      JOIN Frecuencia f ON f.id = p.idFrecuencia
      JOIN Categoria c ON c.id = p.idCategoria
      WHERE p.idUsuario = ?
      ORDER BY p.id DESC
    SQL

    DB.execute(query, [id_usuario])
  end

  def self.create(data)
    query = <<-SQL
      INSERT INTO PagoPlanificado
      (nombre, monto, idCuenta, idUsuario, idCategoria, idTipoTransaccion, 
       idFrecuencia, intervalo, fechaInicio, idTipoPago)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    SQL

    DB.execute(query, [
      data[:nombre], data[:monto], data[:idCuenta], data[:idUsuario],
      data[:idCategoria], data[:idTipoTransaccion], data[:idFrecuencia],
      data[:intervalo], data[:fechaInicio], data[:idTipoPago]
    ])

    DB.last_insert_row_id
  end

  def self.delete(id, id_usuario)
    DB.execute("DELETE FROM PagoPlanificado WHERE id = ? AND idUsuario = ?", [id, id_usuario])
  end

  
  def self.update(id, id_usuario, data)
    query = <<-SQL
        UPDATE PagoPlanificado
        SET nombre = ?, monto = ?, idCuenta = ?, idCategoria = ?, 
            idTipoTransaccion = ?, idFrecuencia = ?, intervalo = ?, 
            fechaInicio = ?, idTipoPago = ?
        WHERE id = ? AND idUsuario = ?
    SQL

    DB.execute(query, [
        data[:nombre], data[:monto], data[:idCuenta], data[:idCategoria],
        data[:idTipoTransaccion], data[:idFrecuencia], data[:intervalo],
        data[:fechaInicio], data[:idTipoPago],
        id, id_usuario
    ])
    end

end
