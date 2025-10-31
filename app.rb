require 'sinatra'
require 'sinatra/json'
require_relative './database'
require_relative './controllers/login_controller'

# Aquí se cargarán los controladores
Dir["./controllers/*.rb"].each { |file| require file }
use LoginController


set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  json message: "API del Proyecto funcionando correctamente 🚀"
end
    