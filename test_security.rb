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

puts "--- Testing Security Controllers ---"

# 1. Enviar Código 2FA
puts "\n1. Enviar Código 2FA (correo válido)"
# Asumimos que existe un usuario con este correo en la BD (creado en tests anteriores o seeds)
# Si no existe, fallará con 404, lo cual también es válido para probar el controller.
# Usaremos 'test@example.com' que suele ser común en seeds, o uno que sepamos que existe.
# En test_auth.rb usamos 'nuevo@usuario.com'.
msg_2fa = { correo: "nuevo@usuario.com" } 
test_endpoint(:post, '/two_factor/send_code', msg_2fa)

# 2. Enviar Código 2FA (correo inválido)
puts "\n2. Enviar Código 2FA (correo no registrado)"
msg_2fa_bad = { correo: "noexiste@mail.com" }
test_endpoint(:post, '/two_factor/send_code', msg_2fa_bad)

# 3. Reset Password
puts "\n3. Reset Password (correo válido)"
msg_reset = { correo: "nuevo@usuario.com" }
test_endpoint(:post, '/reset_password', msg_reset)

# 4. Reset Password (correo vacío)
puts "\n4. Reset Password (correo vacío)"
msg_reset_empty = { correo: "" }
test_endpoint(:post, '/reset_password', msg_reset_empty)
