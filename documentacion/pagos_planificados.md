# Documentación de Endpoints: Pagos Planificados

Esta sección detalla los endpoints gestionados por `PagosPlanificadosController`. Todos los endpoints utilizan una estructura de respuesta genérica estandarizada.

## Estructura de Respuesta Genérica

Todas las respuestas JSON siguen este formato:

```json
{
  "success": boolean,
  "message": "string",
  "data": object | array | null,
  "error": string | null
}
```

---

## Endpoints

### 1. Obtener Catálogos
Obtiene las listas necesarias para poblar los selectores en el formulario de creación/edición (Frecuencias, Categorías, Tipos de Transacción, Tipos de Pago y Cuentas del usuario).

*   **Método**: `GET`
*   **URL**: `/pagos-planificados/catalogos`
*   **Parámetros (Query)**:
    *   `user_id` (Requerido): ID del usuario para filtrar sus cuentas.

**Ejemplo de Respuesta Exitosa:**
```json
{
  "success": true,
  "message": "Catálogos obtenidos correctamente",
  "data": {
    "tipos_transaccion": [{"id": 1, "nombre": "Gasto"}, ...],
    "frecuencias": [{"id": 1, "nombre": "Mensual"}, ...],
    "categorias": [{"id": 1, "nombre": "Comida"}, ...],
    "tipos_pago": [{"id": 1, "nombre": "Efectivo"}, ...],
    "cuentas": [{"id": 1, "nombre": "Banco X", "saldo": 1000, "idMoneda": 1}, ...]
  }
}
```

### 2. Listar Pagos Planificados
Lista todos los pagos planificados configurados por un usuario.

*   **Método**: `GET`
*   **URL**: `/pagos-planificados`
*   **Parámetros (Query)**:
    *   `user_id` (Requerido): ID del usuario.

**Ejemplo de Respuesta Exitosa:**
```json
{
  "success": true,
  "message": "Pagos obtenidos correctamente",
  "data": [
    {
      "id": 10,
      "nombre": "Netflix",
      "monto": 15.0,
      "tipo": "Gasto",
      "periodo": "Mensual",
      "categoria": "Suscripciones",
      "fechaInicio": "2023-12-01",
      "intervalo": 1
    }
  ]
}
```

### 3. Crear Pago Planificado
Registra un nuevo pago planificado.

*   **Método**: `POST`
*   **URL**: `/pagos-planificados`
*   **Cuerpo (JSON)**:
    ```json
    {
      "nombre": "Spotify",
      "monto": 10.0,
      "tipo": "Gasto",          // Debe coincidir con nombre en TipoTransaccion
      "periodo": "Mensual",     // Debe coincidir con nombre en Frecuencia
      "categoria": "Ocio",      // Debe coincidir con nombre en Categoria
      "id_cuenta": 1,
      "tipo_pago": "Tarjeta",   // Debe coincidir con nombre en TipoPago
      "idUsuario": 1,
      "fecha_inicio": "2023-12-05",
      "intervalo": 1            // Opcional, default 1
    }
    ```

**Ejemplo de Respuesta Exitosa:**
```json
{
  "success": true,
  "message": "Pago planificado creado exitosamente",
  "data": {
    "id": 12
  }
}
```

### 4. Actualizar Pago Planificado
Modifica un pago planificado existente.

*   **Método**: `PUT`
*   **URL**: `/pagos-planificados/:id`
*   **Parámetros (Path)**:
    *   `id`: ID del pago planificado.
*   **Cuerpo (JSON)**:
    ```json
    {
      "idUsuario": 1,           // Requerido para verificación
      "nombre": "Spotify Premium",
      "monto": 12.0,
      "tipo": "Gasto",
      "periodo": "Mensual",
      "categoria": "Ocio",
      "id_cuenta": 1,
      "tipo_pago": "Tarjeta",
      "fecha_inicio": "2023-12-05"
    }
    ```

**Ejemplo de Respuesta Exitosa:**
```json
{
  "success": true,
  "message": "Pago planificado actualizado correctamente",
  "data": {
    "id": "12"
  }
}
```

### 5. Eliminar Pago Planificado
Elimina un registro de pago planificado.

*   **Método**: `DELETE`
*   **URL**: `/pagos-planificados/:id`
*   **Parámetros (Path)**:
    *   `id`: ID del pago planificado.
*   **Parámetros (Query)**:
    *   `user_id` (Requerido): ID del usuario para verificar propiedad.

**Ejemplo de Respuesta Exitosa:**
```json
{
  "success": true,
  "message": "Pago planificado eliminado correctamente",
  "data": {
    "id": "12"
  }
}
```
