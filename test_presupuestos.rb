require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:4567'

def request(method, endpoint, body = nil)
  uri = URI("#{BASE_URL}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method
            when :get then Net::HTTP::Get.new(uri)
            when :post then Net::HTTP::Post.new(uri)
            when :put then Net::HTTP::Put.new(uri)
            when :delete then Net::HTTP::Delete.new(uri)
            end

  request['Content-Type'] = 'application/json'
  request.body = body.to_json if body
  
  response = http.request(request)
  puts "--- Request: #{method.upcase} #{endpoint} ---"
  puts "Status: #{response.code}"
  puts "Body: #{response.body}"
  puts "----------------------------------------"
  
  begin
    JSON.parse(response.body)
  rescue
    puts "JSON Parse Error. Raw Body:"
    puts response.body
    response.body
  end
end

puts "Testing Presupuestos Controller..."

# 1. Crear Presupuesto
puts "\n1. Creating Presupuesto..."
create_body = {
  "nombre" => "Test Presupuesto",
  "monto_total" => 500.0,
  "periodo" => "Mensual",
  "user_id" => 1,
  "id_categoria" => 1,
  "id_cuenta" => 1,
  "notificar_exceso" => true
}
response = request(:post, '/presupuestos', create_body)
new_id = response['data']['id'] rescue nil

if new_id
  puts "Created ID: #{new_id}"

  # 2. Listar Presupuestos
  puts "\n2. Listing Presupuestos..."
  request(:get, "/presupuestos?user_id=1")

  # 3. Obtener Detalle
  puts "\n3. Getting Detail..."
  request(:get, "/presupuestos/#{new_id}")

  # 4. Actualizar Presupuesto
  puts "\n4. Updating Presupuesto..."
  update_body = {
    "nombre" => "Test Presupuesto Updated",
    "monto_total" => 600.0,
    "periodo" => "Mensual",
    "user_id" => 1,
    "id_categoria" => 1,
    "id_cuenta" => 1,
    "notificar_exceso" => false
  }
  request(:put, "/presupuestos/#{new_id}", update_body)

  # 5. Eliminar Presupuesto
  puts "\n5. Deleting Presupuesto..."
  request(:delete, "/presupuestos/#{new_id}?user_id=1")
else
  puts "Failed to create presupuesto. Aborting."
end
