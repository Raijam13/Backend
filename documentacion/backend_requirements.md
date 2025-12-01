# Requerimientos de Backend para Aprende Wallet

Este documento detalla los endpoints y estructuras de datos necesarios para soportar las funcionalidades completas de **Pagos Planificados** y **Presupuestos** en la aplicación móvil.

## 1. Pagos Planificados (CRUD Completo)

### Endpoints Requeridos

| Método | Endpoint | Descripción | Parámetros / Body |
|---|---|---|---|
| `GET` | `/pagos-planificados?user_id={id}` | Listar pagos del usuario | Query Param: `user_id` |
| `GET` | `/pagos-planificados/:id?user_id={id}` | Obtener detalle de un pago | Path Param: `id`, Query Param: `user_id` |
| `GET` | `/pagos-planificados/catalogos?user_id={id}` | Obtener listas de selección | Query Param: `user_id` |
| `POST` | `/pagos-planificados` | Crear nuevo pago | Body JSON (ver abajo) |
| `PUT` | `/pagos-planificados/:id` | Actualizar pago existente | Path Param: `id`, Body JSON |
| `DELETE` | `/pagos-planificados/:id?user_id={id}` | Eliminar pago | Path Param: `id`, Query Param: `user_id` |

### Estructura del Body (POST/PUT)
```json
{
  "nombre": "Netflix",
  "monto": 45.90,
  "tipo": "gasto", // "gasto" o "ingreso"
  "periodo": "Mensual",
  "categoria": "Entretenimiento", // Nombre o ID si aplica
  "id_cuenta": 1,
  "tipo_pago": "Efectivo",
  "fecha_inicio": "2023-10-27T10:00:00",
  "intervalo": 1,
  "idUsuario": 1
}
```

### Estructura de Respuesta (GET /catalogos)
```json
{
  "categorias": [{"id": 1, "nombre": "Comida"}, ...],
  "frecuencias": [{"id": 1, "nombre": "Mensual"}, ...],
  "cuentas": [{"id": 1, "nombre": "Efectivo"}, ...],
  "tipos_pago": [{"id": 1, "nombre": "Efectivo"}, ...]
}
```

---

## 2. Presupuestos (CRUD Completo)

### Endpoints Requeridos

| Método | Endpoint | Descripción | Parámetros / Body |
|---|---|---|---|
| `GET` | `/presupuestos?user_id={id}` | Listar presupuestos | Query Param: `user_id` |
| `GET` | `/presupuestos/:id?user_id={id}` | Obtener detalle | Path Param: `id`, Query Param: `user_id` |
| `GET` | `/presupuestos/catalogos?user_id={id}` | Obtener listas (si difieren) | Query Param: `user_id` |
| `POST` | `/presupuestos` | Crear presupuesto | Body JSON (ver abajo) |
| `PUT` | `/presupuestos/:id` | Actualizar presupuesto | Path Param: `id`, Body JSON |
| `DELETE` | `/presupuestos/:id?user_id={id}` | Eliminar presupuesto | Path Param: `id`, Query Param: `user_id` |

### Estructura del Body (POST/PUT)
```json
{
  "nombre": "Gastos Mensuales",
  "monto_total": 1500.00,
  "periodo": "Mensual",
  "id_categoria": 2, // Opcional, si es presupuesto por categoría
  "id_cuenta": 1,    // Opcional
  "user_id": 1,
  "fecha_inicio": "2023-11-01"
}
```

### Notas Importantes
*   **Manejo de Nulos**: Asegurar que los campos opcionales retornen `null` o un valor por defecto consistente, no omitir la clave.
*   **Snake Case vs Camel Case**: El frontend está preparado para manejar ambos, pero se prefiere consistencia (idealmente `snake_case` para APIs REST).
*   **IDs**: Retornar siempre el ID del objeto creado/actualizado en la respuesta.
