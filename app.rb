require 'sinatra'
require 'sinatra/json'
require_relative './database'
require_relative './controllers/login_controller'
require_relative './controllers/registro_controller'
require_relative './controllers/reset_pasword_controller'
require_relative './controllers/perfil_controller'
require_relative './controllers/chat_controller'
require_relative './controllers/eliminar_controller'
require_relative './controllers/two_factor_controller'
require_relative './controllers/pagos_planificados_controller'


# Aquí se cargarán los controladores
Dir["./controllers/*.rb"].each { |file| require file }
use LoginController
use RegistroController
use PerfilController
use ChatController
use EliminarController
use TwoFactorController
use ResetPasswordController
use PagosPlanificadosController

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  json message: "API del Proyecto funcionando correctamente"
end

get '/swagger.yaml' do
  content_type 'application/yaml'
  File.read(File.join(settings.root, 'swagger.yaml'))
end

get '/docs' do
  yaml_url = "#{request.base_url}/swagger.yaml"

  <<~HTML
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>Swagger UI</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.18.3/swagger-ui.css" />
      </head>
      <body>
        <div id="swagger-ui"></div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.18.3/swagger-ui-bundle.js"></script>
        <script>
          window.ui = SwaggerUIBundle({
            url: "#{yaml_url}",
            dom_id: '#swagger-ui'
          });
        </script>
      </body>
    </html>
  HTML
end
