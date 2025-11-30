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

puts "--- Testing Dashboard Controller ---"

# 1. Obtener Resumen (Mes actual)
puts "\n1. Obtener Resumen (user_id=1)"
test_endpoint(:get, '/dashboard/summary?user_id=1')

# 2. Obtener Balance Total
puts "\n2. Obtener Balance Total (user_id=1)"
test_endpoint(:get, '/dashboard/total-balance?user_id=1')

# 3. Error: Falta user_id
puts "\n3. Error: Falta user_id"
test_endpoint(:get, '/dashboard/summary')
