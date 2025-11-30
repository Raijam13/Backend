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
            when :post then Net::HTTP::Post.new(uri)
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

puts "--- Testing Chat Controller ---"

# 1. Enviar Mensaje (Gasto)
puts "\n1. Enviar Mensaje (Gasto)"
msg_gasto = {
  idUsuario: 1,
  mensaje: "He gastado mucho este mes"
}
test_endpoint(:post, '/chat', msg_gasto)

# 2. Enviar Mensaje (Categoría)
puts "\n2. Enviar Mensaje (Categoría)"
msg_cat = {
  idUsuario: 1,
  mensaje: "Cual es mi categoría con más gasto?"
}
test_endpoint(:post, '/chat', msg_cat)

# 3. Obtener Historial
puts "\n3. Obtener Historial (idUsuario=1)"
test_endpoint(:get, '/chat/1')

# 4. Mensaje Vacío (Error)
puts "\n4. Mensaje Vacío"
msg_empty = {
  idUsuario: 1,
  mensaje: ""
}
test_endpoint(:post, '/chat', msg_empty)

# 5. Usuario sin historial (Asumiendo ID 999 no tiene)
puts "\n5. Usuario sin historial (idUsuario=999)"
test_endpoint(:get, '/chat/999')
