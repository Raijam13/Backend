require_relative '../database'

class Mensaje
  # Crear nuevo mensaje
  def self.create(id_usuario, mensaje, fecha_hora)
    query = "INSERT INTO Mensajes (idUsuario, Mensaje, FechaHora) VALUES (?, ?, ?)"
    DB.execute(query, [id_usuario, mensaje, fecha_hora])
    DB.last_insert_row_id
  end

  # Obtener historial por usuario
  def self.find_by_user(id_usuario)
    query = "SELECT * FROM Mensajes WHERE idUsuario = ? ORDER BY FechaHora DESC"
    DB.execute(query, [id_usuario])
  end
end
