require_relative '../database'

class Registro
  def self.find_by_user(id_usuario, limit = 20, offset = 0)
    query = <<~SQL
      SELECT R.id, R.fechaHora, R.monto,
             C.nombre as cuenta,
             T.nombre as tipo,
             Cat.nombre as categoria
      FROM Registro R
      LEFT JOIN Cuenta C ON R.idCuenta = C.id
      LEFT JOIN TipoTransaccion T ON R.idTipoTransaccion = T.id
      LEFT JOIN Categoria Cat ON R.idCategoria = Cat.id
      WHERE R.idUsuario = ?
      ORDER BY R.fechaHora DESC
      LIMIT ? OFFSET ?
    SQL
    DB.execute(query, [id_usuario, limit, offset])
  end

  def self.find_by_id(id)
    query = <<~SQL
      SELECT R.id, R.fechaHora, R.monto, R.idCuenta, R.idUsuario, R.idTipoTransaccion, R.idCategoria,
             C.nombre as cuenta,
             T.nombre as tipo,
             Cat.nombre as categoria
      FROM Registro R
      LEFT JOIN Cuenta C ON R.idCuenta = C.id
      LEFT JOIN TipoTransaccion T ON R.idTipoTransaccion = T.id
      LEFT JOIN Categoria Cat ON R.idCategoria = Cat.id
      WHERE R.id = ?
      LIMIT 1
    SQL
    DB.execute(query, [id]).first
  end

  def self.create(fecha_hora, monto, id_cuenta, id_usuario, id_tipo_transaccion, id_categoria)
    query = "INSERT INTO Registro (fechaHora, monto, idCuenta, idUsuario, idTipoTransaccion, idCategoria) VALUES (?, ?, ?, ?, ?, ?)"
    DB.execute(query, [fecha_hora, monto, id_cuenta, id_usuario, id_tipo_transaccion, id_categoria])
    DB.last_insert_row_id
  end

  def self.delete_by_id(id)
    query = "DELETE FROM Registro WHERE id = ?"
    DB.execute(query, [id])
  end

  def self.get_tipo_transaccion(id_tipo)
    query = "SELECT nombre FROM TipoTransaccion WHERE id = ? LIMIT 1"
    result = DB.execute(query, [id_tipo]).first
    result ? result['nombre'] : nil
  end
end
