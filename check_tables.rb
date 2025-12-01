require_relative './database'

tables = DB.execute("SELECT name FROM sqlite_master WHERE type='table'")
puts "Tables found:"
tables.each do |t|
  puts "- #{t['name']}"
end
