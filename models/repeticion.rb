# models/repeticion.rb

require_relative '../database'

class Repeticion
  def self.create(id_pago, data)
    query = <<-SQL
      INSERT INTO Repeticion (idPagoPlanificado, finTipo, fechaFin, conteoEventos)
      VALUES (?, ?, ?, ?)
    SQL

    DB.execute(query, [
      id_pago,
      data[:finTipo],
      data[:fechaFin],
      data[:conteoEventos]
    ])
  end

  def self.update(id_pago, data)
    query = <<-SQL
        UPDATE Repeticion
        SET finTipo = ?, fechaFin = ?, conteoEventos = ?
        WHERE idPagoPlanificado = ?
    SQL

    DB.execute(query, [
        data[:finTipo], data[:fechaFin], data[:conteoEventos],
        id_pago
    ])
    end

end
