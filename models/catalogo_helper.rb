# models/catalogo_helper.rb
# Contiene la lógica para listar y buscar IDs de cualquier tabla de catálogo

require_relative '../database'

module CatalogoHelper
  # Obtiene todos los elementos (id, nombre) de una tabla (útil para dropdowns)
  def self.list_all(table_name)
    query = "SELECT id, nombre FROM #{table_name} ORDER BY nombre ASC"
    DB.execute(query)
  end

  # Obtiene el ID de un elemento de catálogo por su nombre (útil para la inserción)
  def self.find_id_by_nombre(table_name, nombre)
    query = "SELECT id FROM #{table_name} WHERE nombre = ? LIMIT 1"
    result = DB.execute(query, [nombre]).first
    result ? result['id'] : nil
  end
end