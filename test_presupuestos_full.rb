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
  puts "--- #{method.upcase} #{endpoint} ---"
  puts "Status: #{response.code}"
  
  begin
    parsed = JSON.parse(response.body)
    puts "Success: #{parsed['success']}"
    puts "Message: #{parsed['message']}"
    puts "Data: #{parsed['data'].inspect[0..100]}..." if parsed['data']
    parsed
  rescue => e
    puts "Parse Error: #{e.message}"
    puts "Body: #{response.body[0..200]}"
    nil
  end
ensure
  puts "----------------------------------------"
end

puts "=== Testing Presupuestos Controller (Full) ==="
puts

# 0. Test Catalogos
puts "0. Getting Catalogos..."
catalogos = request(:get, "/presupuestos/catalogos?user_id=1")

if catalogos && catalogos['success']
  puts "✅ Catalogos retrieved"
  puts "  - Categorias: #{catalogos['data']['categorias']&.size || 0}"
  puts "  - Periodos: #{catalogos['data']['periodos']&.size || 0}"
  puts "  - Cuentas: #{catalogos['data']['cuentas']&.size || 0}"
else
  puts "❌ Failed to get catalogos"
end

puts

# 1. Crear Presupuesto
puts "1. Creating Presupuesto..."
create_body = {
  "nombre" => "Test Presupuesto",
  "monto_total" => 500.0,
  "periodo" => "Mensual",
  "user_id" => 1,
  "notificar_exceso" => true
}
response = request(:post, '/presupuestos', create_body)
new_id = response&.dig('data', 'id')

if new_id
  puts "✅ Created with ID: #{new_id}"
  puts

  # 2. Listar Presupuestos
  puts "2. Listing Presupuestos..."
  list_response = request(:get, "/presupuestos?user_id=1")
  if list_response && list_response['success']
    puts "✅ Listed #{list_response['data']&.size || 0} presupuestos"
  end
  puts

  # 3. Obtener Detalle
  puts "3. Getting Detail..."
  detail = request(:get, "/presupuestos/#{new_id}")
  if detail && detail['success']
    puts "✅ Detail retrieved for: #{detail['data']['nombre']}"
  end
  puts

  # 4. Actualizar Presupuesto
  puts "4. Updating Presupuesto..."
  update_body = {
    "nombre" => "Test Presupuesto Updated",
    "monto_total" => 600.0,
    "periodo" => "Mensual",
    "user_id" => 1,
    "notificar_exceso" => false
  }
  update_response = request(:put, "/presupuestos/#{new_id}", update_body)
  if update_response && update_response['success']
    puts "✅ Updated successfully"
  end
  puts

  # 5. Eliminar Presupuesto
  puts "5. Deleting Presupuesto..."
  delete_response = request(:delete, "/presupuestos/#{new_id}?user_id=1")
  if delete_response && delete_response['success']
    puts "✅ Deleted successfully"
  end
  puts

  puts "=== All Tests Completed ==="
else
  puts "❌ Failed to create presupuesto. Aborting remaining tests."
  puts "Check that server is running: ruby app.rb"
end
