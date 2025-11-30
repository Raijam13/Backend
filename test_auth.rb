require 'net/http'
require 'json'
require 'uri'

$stdout.sync = true

BASE_URL = 'http://localhost:4567'

def test_endpoint(method, path, body = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method
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

puts "--- Testing Auth Controllers ---"

# Generar datos aleatorios para evitar conflictos
timestamp = Time.now.to_i
email = "test_user_#{timestamp}@example.com"

# 1. Registro Exitoso
puts "\n1. Registro Exitoso"
new_user = {
  nombres: "Test",
  apellidos: "User",
  correo: email,
  contrasena: "password123"
}
test_endpoint(:post, '/registro', new_user)

# 2. Registro Duplicado (Debe fallar con 409)
puts "\n2. Registro Duplicado"
test_endpoint(:post, '/registro', new_user)

# 3. Login Exitoso
puts "\n3. Login Exitoso"
login_data = {
  correo: email,
  contraseña: "password123"
}
test_endpoint(:post, '/login', login_data)

# 4. Login Fallido
puts "\n4. Login Fallido"
bad_login = {
  correo: email,
  contraseña: "wrongpassword"
}
test_endpoint(:post, '/login', bad_login)
