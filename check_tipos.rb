require 'sqlite3'

begin
  db = SQLite3::Database.new 'db/proyecto.db'
  db.results_as_hash = true

  puts "--- TipoCuenta ---"
  db.execute("SELECT * FROM TipoCuenta").each do |row|
    puts "#{row['id']}: #{row['nombre']}"
  end
rescue => e
  puts "Error: #{e.message}"
end
