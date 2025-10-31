require_relative '../database'

class Usuario
  def self.find_by_credentials(correo, contraseña)
    query = "SELECT * FROM Usuario WHERE correo = ? AND contraseña = ? LIMIT 1"
    DB.execute(query, [correo, contraseña]).first
  end
end
