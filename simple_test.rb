require 'net/http'
require 'json'
require 'uri'

uri = URI('http://localhost:4567/presupuestos')
http = Net::HTTP.new(uri.host, uri.port)

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  "nombre" => "Test",
  "monto_total" => 500,
  "periodo" => "Mensual",
  "user_id" => 1
}.to_json

response = http.request(request)
puts "Status: #{response.code}"
puts "Body:"
puts response.body
