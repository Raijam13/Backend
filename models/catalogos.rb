# models/catalogos.rb
# Define todas las clases de catálogo necesarias para los Pagos Planificados

require_relative '../database'
require_relative './catalogo_helper'

class Frecuencia
  def self.all
    CatalogoHelper.list_all('Frecuencia') # Busca en la tabla Frecuencia
  end
  def self.find_id_by_nombre(nombre)
    CatalogoHelper.find_id_by_nombre('Frecuencia', nombre)
  end
end

class Categoria
  def self.all
    CatalogoHelper.list_all('Categoria') # Busca en la tabla Categoria
  end
  def self.find_id_by_nombre(nombre)
    CatalogoHelper.find_id_by_nombre('Categoria', nombre)
  end
end

class TipoTransaccion
  def self.all
    CatalogoHelper.list_all('TipoTransaccion') # Busca en la tabla TipoTransaccion
  end
  def self.find_id_by_nombre(nombre)
    CatalogoHelper.find_id_by_nombre('TipoTransaccion', nombre)
  end
end

class TipoPago
  def self.all
    CatalogoHelper.list_all('TipoPago') # Busca en la tabla TipoPago
  end
  def self.find_id_by_nombre(nombre)
    CatalogoHelper.find_id_by_nombre('TipoPago', nombre)
  end
end

class Cuenta
  # La tabla Cuenta es diferente, pues depende del usuario.
  def self.find_by_user(id_usuario)
    query = "SELECT id, nombre, saldo, idMoneda FROM Cuenta WHERE idUsuario = ?"
    DB.execute(query, [id_usuario])
  end
  # Necesitas métodos para Moneda y TipoCuenta si los usas en el listado de Cuentas...
end