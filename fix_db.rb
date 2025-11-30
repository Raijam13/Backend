require 'sqlite3'

begin
  db = SQLite3::Database.new 'db/proyecto.db'
  db.results_as_hash = true

  puts "Checking columns..."
  columns = db.execute("PRAGMA table_info(PagoPlanificado)").map { |c| c['name'] }

  unless columns.include?('idFrecuencia')
    puts "Adding idFrecuencia..."
    db.execute("ALTER TABLE PagoPlanificado ADD COLUMN idFrecuencia INTEGER")
  end

  unless columns.include?('intervalo')
    puts "Adding intervalo..."
    db.execute("ALTER TABLE PagoPlanificado ADD COLUMN intervalo INTEGER DEFAULT 1")
  end

  unless columns.include?('finTipo')
    puts "Adding finTipo..."
    db.execute("ALTER TABLE PagoPlanificado ADD COLUMN finTipo TEXT DEFAULT 'NUNCA'")
  end

  puts "Seeding Frecuencia..."
  frecuencias = ['Diario', 'Semanal', 'Mensual', 'Anual']
  frecuencias.each do |f|
    exists = db.execute("SELECT 1 FROM Frecuencia WHERE nombre = ?", [f]).first
    unless exists
      db.execute("INSERT INTO Frecuencia (nombre) VALUES (?)", [f])
      puts "Inserted #{f}"
    end
  end

  puts "Seeding TipoPago..."
  tipos = ['Efectivo', 'Tarjeta de Crédito', 'Tarjeta de Débito', 'Transferencia']
  tipos.each do |t|
    exists = db.execute("SELECT 1 FROM TipoPago WHERE nombre = ?", [t]).first
    unless exists
      db.execute("INSERT INTO TipoPago (nombre) VALUES (?)", [t])
      puts "Inserted #{t}"
    end
  end

  puts "Done!"

rescue => e
  puts "Error: #{e.message}"
end
