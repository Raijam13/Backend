# Reporte de Situación Actual del Backend

## 1. Visión General
El proyecto es un backend desarrollado en **Ruby** utilizando el framework **Sinatra**. La base de datos es **SQLite3**. La arquitectura sigue un patrón MVC (Modelo-Vista-Controlador), donde las "Vistas" son respuestas JSON para una aplicación móvil (Flutter).

## 2. Estructura de la Base de Datos
Basado en el análisis de los modelos y el código, la estructura de la base de datos relacional es la siguiente:

### Tablas Principales
*   **Usuario**: Almacena la información de los usuarios.
    *   Columnas: `id`, `nombres`, `apellidos`, `correo`, `contraseña`, `imagen_perfil`.
*   **Cuenta**: Cuentas de ahorro/dinero del usuario.
    *   Columnas: `id`, `nombre`, `saldo`, `idUsuario`, `idMoneda`, `idTipoCuenta`.
*   **Registro**: Transacciones (ingresos/gastos).
    *   Columnas: `id`, `fechaHora`, `monto`, `idCuenta`, `idUsuario`, `idTipoTransaccion`, `idCategoria`.
*   **PagoPlanificado**: Pagos recurrentes o futuros.
    *   Columnas: `id`, `nombre`, `monto`, `idCuenta`, `idUsuario`, `idCategoria`, `idTipoTransaccion`, `idFrecuencia`, `intervalo`, `fechaInicio`, `idTipoPago`.
*   **Mensajes**: Historial de chat (simulación IA).
    *   Columnas: `idUsuario`, `Mensaje`, `FechaHora`.

### Catálogos
*   **Categoria**: Categorías de gastos/ingresos.
*   **TipoTransaccion**: Tipo de movimiento (Ingreso, Gasto, etc.).
*   **Frecuencia**: Frecuencia de pagos planificados (Diario, Semanal, etc.).
*   **TipoPago**: Método de pago.
*   **Moneda**: Divisas soportadas (`code`, `nombre`).
*   **TipoCuenta**: Tipos de cuenta (Ahorro, Corriente, Efectivo, etc.).

## 3. Arquitectura del Proyecto

### Estructura de Directorios
*   `app.rb`: Punto de entrada de la aplicación. Carga controladores y configura rutas base.
*   `controllers/`: Contiene la lógica de los endpoints. Cada archivo maneja un recurso (ej. `CuentasController`).
*   `models/`: Capa de acceso a datos (DAO). Contiene las consultas SQL directas.
*   `db/`: Archivos de base de datos SQLite.

### Implementación Actual
*   **Controladores**:
    *   Heredan de `Sinatra::Base`.
    *   Manejan manualmente el parseo de JSON (`JSON.parse(request.body.read)`).
    *   Construyen las respuestas JSON manualmente (Hash `.to_json`).
    *   **Manejo de Errores**: Repetitivo. Cada ruta tiene un bloque `begin/rescue` para capturar errores de JSON, SQLite y generales.
    *   **Validaciones**: Se realizan dentro del controlador (ej. verificar campos nulos).
*   **Modelos**:
    *   Utilizan la gema `sqlite3` para ejecutar consultas SQL crudas (`DB.execute`).
    *   No se utiliza un ORM (como ActiveRecord), lo cual es válido para un proyecto ligero pero requiere más mantenimiento de SQL manual.
*   **Autenticación**:
    *   `LoginController` verifica credenciales (correo/contraseña).
    *   No parece haber un sistema de tokens (JWT) o sesiones persistentes implementado en el código analizado; el login devuelve los datos del usuario directamente.

## 4. Análisis para "Endpoints Agnósticos" y `genericResponse`

Actualmente, las respuestas no siguen una estructura estricta y uniforme en todos los casos, aunque intentan mantener `{ status, message, ... }`.

### Problemas Identificados
1.  **Redundancia**: El código de manejo de errores (`halt 500`, `halt 400`) se repite en cada método.
2.  **Acoplamiento**: Los controladores conocen demasiado sobre la estructura de la base de datos (algunas validaciones de FK se hacen con queries directas en el controlador).
3.  **Consistencia**: Si se decide cambiar el formato de respuesta (ej. agregar un campo `timestamp`), se tendría que editar cada controlador.

### Recomendaciones
Para lograr que los controladores respondan usando `genericResponse` y sean agnósticos:
1.  **Crear un Helper `GenericResponse`**: Un módulo o clase que estandarice la salida JSON.
    *   Estructura sugerida: `{ "success": true/false, "message": "...", "data": { ... }, "errors": [...] }`.
2.  **Middleware de Errores**: Centralizar el manejo de excepciones (`rescue`) para no repetirlo en cada ruta.
3.  **Servicios**: Mover la lógica de negocio (validaciones complejas, cálculos) fuera de los controladores a una capa de servicios, dejando los controladores solo para manejar HTTP.
