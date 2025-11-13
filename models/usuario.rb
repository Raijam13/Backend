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
  
  def self.find_by_id(id)
    query = "SELECT * FROM Usuario WHERE id = ? LIMIT 1"
    DB.execute(query, [id]).first
  end
  
  def self.update_partial(id, data)
    set_clause = []
    values = []

    data.each do |campo, valor|
      next if valor.nil? || valor.strip.empty?
      set_clause << "#{campo} = ?"
      values << valor
    end

    return if set_clause.empty?

    query = "UPDATE Usuario SET #{set_clause.join(', ')} WHERE id = ?"
    values << id
    DB.execute(query, values)
  end

end
