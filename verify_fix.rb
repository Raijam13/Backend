require 'net/http'
require 'json'
require 'uri'

uri = URI('http://localhost:4567/registros?user_id=1')
res = Net::HTTP.get_response(uri)

if res.is_a?(Net::HTTPSuccess)
  json = JSON.parse(res.body)
  puts JSON.pretty_generate(json)
else
  puts "Error: #{res.code} - #{res.message}"
end
