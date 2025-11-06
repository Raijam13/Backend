require_relative '../database'

class Usuario
  def self.find_by_credentials(correo, contraseña)
    query = "SELECT * FROM Usuario WHERE correo = ? AND contraseña = ? LIMIT 1"
    DB.execute(query, [correo, contraseña]).first
  end

  def self.find_by_email(correo)
    query = "SELECT * FROM Usuario WHERE correo = ? LIMIT 1"
    DB.execute(query, [correo]).first
  end

  def self.create(nombres, apellidos, correo, contraseña)
    query = "INSERT INTO Usuario (nombres, apellidos, correo, contraseña) VALUES (?, ?, ?, ?)"
    DB.execute(query, [nombres, apellidos, correo, contraseña])
    DB.last_insert_row_id
  end
end
