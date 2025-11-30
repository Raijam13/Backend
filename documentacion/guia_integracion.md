# Guía de Integración Frontend

Esta guía detalla el estado actual de la API y cómo consumirla desde la aplicación móvil (Flutter).

## 1. URL Base
La API se ejecuta localmente en:
`http://localhost:4567` (o tu IP local si pruebas desde un dispositivo físico).

## 2. Formatos de Respuesta

> [!WARNING]
> Actualmente existen **dos formatos de respuesta** conviviendo en la API. Debes manejar ambos casos en tu cliente HTTP hasta que se complete la refactorización.

### A. Nuevo Formato Estándar (Recomendado)
Utilizado por: **Pagos Planificados** (`/pagos-planificados/*`).
Este formato será el estándar para toda la API en el futuro.

```json
{
  "success": true, // o false
  "message": "Descripción del resultado",
  "data": { ... }, // Objeto o Array con la información solicitada
  "error": null    // Detalle del error si success es false
}
```

### B. Formato Legacy (Antiguo)
Utilizado por: **Cuentas, Chat, Perfil, Login, Registro**.
Este formato varía ligeramente entre controladores.

```json
{
  "status": "ok", // o "error"
  "message": "Descripción",
  "cuenta": { ... } // El nombre de la clave de datos CAMBIA según el endpoint (ej. "usuario", "historial")
}
```

## 3. Autenticación Temporal
Mientras se implementa JWT, la autenticación se maneja pasando el ID del usuario explícitamente.

*   **GET / DELETE**: Enviar parámetro Query `?user_id=1`.
*   **POST / PUT**: Enviar campo `"idUsuario": 1` en el cuerpo JSON.

## 4. Endpoints Listos para Integrar (Nuevo Formato)

### Pagos Planificados
Consulta la documentación detallada en: `documentacion/pagos_planificados.md`.

*   `GET /pagos-planificados/catalogos?user_id=1` -> Obtiene listas para dropdowns.
*   `GET /pagos-planificados?user_id=1` -> Lista pagos.
*   `POST /pagos-planificados` -> Crea pago.
*   `PUT /pagos-planificados/:id` -> Edita pago.
*   `DELETE /pagos-planificados/:id?user_id=1` -> Elimina pago.

## 5. Swagger UI
Para ver y probar todos los endpoints disponibles (incluyendo los legacy):
[http://localhost:4567/docs](http://localhost:4567/docs)
