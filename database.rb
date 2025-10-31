require 'sqlite3'

DB = SQLite3::Database.new 'db/proyecto.db'
DB.results_as_hash = true
