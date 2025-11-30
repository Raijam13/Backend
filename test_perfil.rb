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
            when :put then Net::HTTP::Put.new(uri)
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

puts "--- Testing Perfil Controller ---"

# 1. Obtener Perfil (Asumiendo usuario ID 1 existe del test anterior)
puts "\n1. Obtener Perfil (id=1)"
test_endpoint(:get, '/perfil/1')

# 2. Actualizar Perfil
puts "\n2. Actualizar Perfil (id=1)"
update_data = {
  nombres: "Usuario Modificado",
  apellidos: "Test Ruby",
  genero: "M"
}
test_endpoint(:put, '/perfil/1', update_data)

# 3. Verificar Actualización
puts "\n3. Verificar Actualización (id=1)"
test_endpoint(:get, '/perfil/1')

# 4. Usuario No Encontrado
puts "\n4. Usuario No Encontrado (id=999)"
test_endpoint(:get, '/perfil/999')
