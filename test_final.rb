require 'net/http'
require 'json'
require 'uri'

$stdout.sync = true

BASE_URL = 'http://localhost:4567'

def test_endpoint(method, path, body = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method
            when :get then Net::HTTP::Get.new(uri)
            when :delete then Net::HTTP::Delete.new(uri)
            end
  
  request['Content-Type'] = 'application/json'
  request.body = body.to_json if body

  puts "\n--- Request: #{method.upcase} #{path} ---"
  puts "Body: #{body.to_json}" if body
  
  begin
    response = http.request(request)
    puts "Response Status: #{response.code}"
    puts "Response Body: #{response.body}"
    JSON.parse(response.body)
  rescue => e
    puts "HTTP Request Failed: #{e.message}"
    nil
  end
end

puts "--- Testing Final Controllers ---"

# 1. Categorías
puts "\n1. Listar Categorías"
test_endpoint(:get, '/categorias')

# 2. Monedas
puts "\n2. Listar Monedas"
test_endpoint(:get, '/monedas')

# 3. Tipos Cuenta
puts "\n3. Listar Tipos Cuenta"
test_endpoint(:get, '/tipos-cuenta')

# 4. Tipos Transacción
puts "\n4. Listar Tipos Transacción"
test_endpoint(:get, '/tipos-transaccion')

# 5. Eliminar Cuenta (Error 404 - Usuario no existe)
puts "\n5. Eliminar Cuenta (ID 9999)"
test_endpoint(:delete, '/cuenta/9999')

# 6. Eliminar Cuenta (Error 401 - Contraseña incorrecta)
# Asumiendo que existe usuario 1 con contraseña '123456' (según seeds típicos)
# Si no existe, dará 404, lo cual también es válido.
puts "\n6. Eliminar Cuenta (Contraseña incorrecta)"
msg_delete = { confirm_password: "wrong_password" }
test_endpoint(:delete, '/cuenta/1', msg_delete)
