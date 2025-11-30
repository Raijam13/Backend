require 'net/http'
require 'json'
require 'uri'

$stdout.sync = true # Force flush

BASE_URL = 'http://localhost:4567'

def test_endpoint(method, path, body = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method
            when :get then Net::HTTP::Get.new(uri)
            when :post then Net::HTTP::Post.new(uri)
            when :put then Net::HTTP::Put.new(uri)
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

puts "--- Testing Cuentas Controller ---"

# 1. Listar Cuentas (GET)
puts "\n1. Listar Cuentas (user_id=1)"
test_endpoint(:get, '/cuentas?user_id=1')

# 2. Crear Cuenta (POST)
puts "\n2. Crear Cuenta"
new_account = {
  nombre: "Cuenta Test Ruby #{Time.now.to_i}",
  saldo: 500.0,
  idUsuario: 1,
  codeMoneda: "PEN",
  tipoCuenta: "Cuenta de ahorros" 
}
response = test_endpoint(:post, '/cuentas', new_account)

if response && response['success']
  id_cuenta = response['data']['id']
  puts ">> Cuenta creada con ID: #{id_cuenta}"

  # 3. Obtener Detalle (GET)
  puts "\n3. Obtener Detalle (id=#{id_cuenta})"
  test_endpoint(:get, "/cuentas/#{id_cuenta}")

  # 4. Actualizar Cuenta (PUT)
  puts "\n4. Actualizar Cuenta (id=#{id_cuenta})"
  update_data = {
    nombre: "Cuenta Test Actualizada",
    saldo: 600.0,
    idUsuario: 1 
  }
  test_endpoint(:put, "/cuentas/#{id_cuenta}", update_data)

  # 5. Eliminar Cuenta (DELETE)
  puts "\n5. Eliminar Cuenta (id=#{id_cuenta})"
  test_endpoint(:delete, "/cuentas/#{id_cuenta}?user_id=1")
else
  puts ">> CREATION FAILED. Stopping tests."
end
