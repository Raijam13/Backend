require_relative './database'

puts "Presupuesto Schema:"
DB.execute('PRAGMA table_info(Presupuesto)').each do |c|
  notnull = c['notnull'] == 1 ? 'NOT NULL' : 'NULL'
  puts "  #{c['name']}: #{c['type']} #{notnull}"
end
