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

puts "--- Testing Registros Controller ---"

# 1. Listar Registros (GET)
puts "\n1. Listar Registros (user_id=1)"
test_endpoint(:get, '/registros?user_id=1')

# 2. Crear Registro (Gasto)
puts "\n2. Crear Registro (Gasto)"
new_registro = {
  idUsuario: 1,
  idCuenta: 1, # Asumiendo que cuenta 1 existe y es de usuario 1
  idCategoria: 1, # Comida
  idTipoTransaccion: 1, # Gasto
  monto: 50.0,
  fechaHora: Time.now.strftime('%Y-%m-%d %H:%M:%S')
}
response = test_endpoint(:post, '/registros', new_registro)

if response && response['success']
  id_registro = response['data']['id']
  puts ">> Registro creado con ID: #{id_registro}"

  # 3. Obtener Detalle (GET)
  puts "\n3. Obtener Detalle (id=#{id_registro})"
  test_endpoint(:get, "/registros/#{id_registro}")

  # 4. Eliminar Registro (DELETE)
  puts "\n4. Eliminar Registro (id=#{id_registro})"
  test_endpoint(:delete, "/registros/#{id_registro}?user_id=1")
else
  puts ">> CREATION FAILED. Stopping tests."
end

# 5. Test de Seguridad: Intentar crear registro en cuenta ajena (si existiera usuario 2 y cuenta 2)
# Para este test, intentaremos usar una cuenta inexistente o que sepamos que fallará si no es nuestra
puts "\n5. Test Seguridad: Cuenta Inexistente (Simulando ajena/error)"
bad_registro = {
  idUsuario: 1,
  idCuenta: 999999, 
  idCategoria: 1,
  idTipoTransaccion: 1,
  monto: 10.0
}
test_endpoint(:post, '/registros', bad_registro)
