require_relative '../database'

class Presupuesto
  # Listar presupuestos de un usuario
  def self.all_by_user(user_id)
    query = <<~SQL
      SELECT P.id, P.nombre, P.monto, P.notificarExceso,
             P.idCuenta, P.idUsuario, P.idPeriodoPresupuesto, P.idCategoria, P.idTipoTransaccion,
             C.nombre as categoria,
             Cu.nombre as cuenta,
             F.nombre as periodo
      FROM Presupuesto P
      LEFT JOIN Categoria C ON P.idCategoria = C.id
      LEFT JOIN Cuenta Cu ON P.idCuenta = Cu.id
      LEFT JOIN PeriodoPresupuesto F ON P.idPeriodoPresupuesto = F.id
      WHERE P.idUsuario = ?
    SQL
    DB.execute(query, [user_id])
  end

  # Obtener un presupuesto por ID
  def self.find_by_id(id)
    query = <<~SQL
      SELECT P.id, P.nombre, P.monto, P.notificarExceso,
             P.idCuenta, P.idUsuario, P.idPeriodoPresupuesto, P.idCategoria, P.idTipoTransaccion,
             C.nombre as categoria,
             Cu.nombre as cuenta,
             F.nombre as periodo
      FROM Presupuesto P
      LEFT JOIN Categoria C ON P.idCategoria = C.id
      LEFT JOIN Cuenta Cu ON P.idCuenta = Cu.id
      LEFT JOIN PeriodoPresupuesto F ON P.idPeriodoPresupuesto = F.id
      WHERE P.id = ?
    SQL
    DB.execute(query, [id]).first
  end

  # Crear un presupuesto
  def self.create(data)
    query = <<~SQL
      INSERT INTO Presupuesto (nombre, monto, notificarExceso, idCuenta, idUsuario, idPeriodoPresupuesto, idCategoria, idTipoTransaccion)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    SQL
    DB.execute(query, [
      data[:nombre],
      data[:monto],
      data[:notificarExceso] || 0,
      data[:idCuenta],
      data[:idUsuario],
      data[:idPeriodoPresupuesto],
      data[:idCategoria],
      data[:idTipoTransaccion]
    ])
    DB.last_insert_row_id
  end

  # Actualizar un presupuesto
  def self.update(id, user_id, data)
    # Verificar propiedad antes de actualizar (opcional pero recomendado)
    # Aquí asumimos que el controlador ya validó o que confiamos en el user_id pasado
    query = <<~SQL
      UPDATE Presupuesto
      SET nombre = ?, monto = ?, notificarExceso = ?, idCuenta = ?, idPeriodoPresupuesto = ?, idCategoria = ?, idTipoTransaccion = ?
      WHERE id = ? AND idUsuario = ?
    SQL
    DB.execute(query, [
      data[:nombre],
      data[:monto],
      data[:notificarExceso] || 0,
      data[:idCuenta],
      data[:idPeriodoPresupuesto],
      data[:idCategoria],
      data[:idTipoTransaccion],
      id,
      user_id
    ])
  end

  # Eliminar un presupuesto
  def self.delete(id, user_id)
    query = "DELETE FROM Presupuesto WHERE id = ? AND idUsuario = ?"
    DB.execute(query, [id, user_id])
  end
end
