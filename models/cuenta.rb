require_relative '../database'

class Cuenta
  def self.find_by_user(id_usuario)
    query = <<~SQL
      SELECT C.id, C.nombre, C.saldo, 
             M.code as moneda_code, M.nombre as moneda_nombre,
             TC.nombre as tipo_cuenta
      FROM Cuenta C
      LEFT JOIN Moneda M ON C.idMoneda = M.id
      LEFT JOIN TipoCuenta TC ON C.idTipoCuenta = TC.id
      WHERE C.idUsuario = ?
      ORDER BY C.nombre
    SQL
    DB.execute(query, [id_usuario])
  end

  def self.find_by_id(id)
    query = <<~SQL
      SELECT C.id, C.nombre, C.saldo, C.idUsuario,
             M.code as moneda_code, M.nombre as moneda_nombre,
             TC.nombre as tipo_cuenta
      FROM Cuenta C
      LEFT JOIN Moneda M ON C.idMoneda = M.id
      LEFT JOIN TipoCuenta TC ON C.idTipoCuenta = TC.id
      WHERE C.id = ?
      LIMIT 1
    SQL
    DB.execute(query, [id]).first
  end

  def self.create(nombre, saldo, id_usuario, id_moneda, id_tipo_cuenta)
    query = "INSERT INTO Cuenta (nombre, saldo, idUsuario, idMoneda, idTipoCuenta) VALUES (?, ?, ?, ?, ?)"
    DB.execute(query, [nombre, saldo, id_usuario, id_moneda, id_tipo_cuenta])
    DB.last_insert_row_id
  end

  def self.update(id, nombre, saldo, id_tipo_cuenta)
    query = "UPDATE Cuenta SET nombre = ?, saldo = ?, idTipoCuenta = ? WHERE id = ?"
    DB.execute(query, [nombre, saldo, id_tipo_cuenta, id])
  end

  def self.update_saldo(id, nuevo_saldo)
    query = "UPDATE Cuenta SET saldo = ? WHERE id = ?"
    DB.execute(query, [nuevo_saldo, id])
  end

  def self.delete_by_id(id)
    query = "DELETE FROM Cuenta WHERE id = ?"
    DB.execute(query, [id])
  end
end
