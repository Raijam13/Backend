require_relative './database'

puts "Starting migration: Making idCuenta and idCategoria nullable..."

# Step 1: Create new table with correct schema
DB.execute(<<~SQL)
  CREATE TABLE IF NOT EXISTS Presupuesto_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    notificarExceso INTEGER,
    idCuenta INTEGER,
    idUsuario INTEGER NOT NULL,
    monto REAL NOT NULL,
    idPeriodoPresupuesto INTEGER,
    idCategoria INTEGER,
    idTipoTransaccion INTEGER,
    FOREIGN KEY(idCuenta) REFERENCES Cuenta(id),
    FOREIGN KEY(idCategoria) REFERENCES Categoria(id),
    FOREIGN KEY(idPeriodoPresupuesto) REFERENCES PeriodoPresupuesto(id),
    FOREIGN KEY(idTipoTransaccion) REFERENCES TipoTransaccion(id),
    FOREIGN KEY(idUsuario) REFERENCES Usuario(id)
  )
SQL

puts "Created Presupuesto_new table"

# Step 2: Copy data from old table to new table
count = DB.execute("SELECT COUNT(*) FROM Presupuesto").first[0]
puts "Found #{count} rows to migrate"

if count > 0
  DB.execute(<<~SQL)
    INSERT INTO Presupuesto_new (id, nombre, notificarExceso, idCuenta, idUsuario, monto, idPeriodoPresupuesto, idCategoria, idTipoTransaccion)
    SELECT id, nombre, notificarExceso, idCuenta, idUsuario, monto, idPeriodoPresupuesto, idCategoria, idTipoTransaccion
    FROM Presupuesto
  SQL
  puts "Copied data"
end

# Step 3: Drop old table
DB.execute("DROP TABLE Presupuesto")
puts "Dropped old Presupuesto table"

# Step 4: Rename new table
DB.execute("ALTER TABLE Presupuesto_new RENAME TO Presupuesto")
puts "Renamed Presupuesto_new to Presupuesto"

puts "Migration complete!"
