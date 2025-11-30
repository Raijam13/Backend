require 'sinatra'
require 'sinatra/json'
require_relative './database'
# Controllers are loaded dynamically from the controllers/ folder

# Aquí se cargarán los controladores desde la carpeta controllers
Dir["./controllers/*.rb"].each { |file| require file }

# Controladores de autenticación y usuario
use LoginController
use RegistroController
use PerfilController
use EliminarController
use TwoFactorController
use ResetPasswordController

# Controladores de funcionalidad principal
use ChatController
use PagosPlanificadosController

# Controladores de catálogos
use CategoriasController
use MonedasController
use TiposCuentaController
use TiposTransaccionController

# Controladores CRUD
use CuentasController
use RegistrosController

# Controladores de analytics
use DashboardController

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
