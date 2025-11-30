require 'sqlite3'
require 'json'

begin
  db = SQLite3::Database.new 'db/proyecto.db'
  db.results_as_hash = true

  puts "--- Columns in PagoPlanificado ---"
  columns = db.execute("PRAGMA table_info(PagoPlanificado)")
  columns.each { |c| puts c['name'] }

  puts "\n--- Count Frecuencia ---"
  count_freq = db.execute("SELECT COUNT(*) as c FROM Frecuencia").first['c']
  puts count_freq

  puts "\n--- Count TipoPago ---"
  count_pago = db.execute("SELECT COUNT(*) as c FROM TipoPago").first['c']
  puts count_pago

rescue => e
  puts "Error: #{e.message}"
end
