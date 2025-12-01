require_relative './database'

# Limpiar tabla por si acaso (opcional, pero seguro para evitar duplicados si se corre varias veces)
# DB.execute("DELETE FROM PeriodoPresupuesto") 

# Verificar si ya tiene datos
count = DB.execute("SELECT COUNT(*) as c FROM PeriodoPresupuesto").first['c']

if count == 0
  puts "Populating PeriodoPresupuesto..."
  periods = ['Mensual', 'Semanal', 'Anual', 'Diario']
  periods.each do |p|
    DB.execute("INSERT INTO PeriodoPresupuesto (nombre) VALUES (?)", [p])
  end
  puts "Done."
else
  puts "PeriodoPresupuesto already has data."
end
