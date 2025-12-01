# Reporte de Errores del Backend

## Problema Crítico: Datos Nulos en Transacciones

La aplicación móvil está experimentando cierres inesperados (crashes) debido a que el endpoint de transacciones está devolviendo valores `null` en campos obligatorios para la UI.

### Detalles del Error
- **Error:** `_TypeError (type 'Null' is not a subtype of type 'int')`
- **Ubicación:** `home_page.dart`
- **Causa:** El campo `color` (y posiblemente `amount` o `subtitle`) viene como `null` en el JSON de respuesta.

### Campos Afectados
Se ha detectado que los siguientes campos pueden llegar nulos o con tipos de datos inconsistentes:

1.  **`color`**:
    *   **Esperado:** `int` (valor ARGB, ej: `4294967295`)
    *   **Recibido:** `null`
    *   **Impacto:** Crash inmediato al intentar renderizar el ícono de la transacción.

2.  **`amount`**:
    *   **Esperado:** `double` o `int`
    *   **Recibido:** Posiblemente `null`
    *   **Impacto:** Error al intentar formatear el monto (`toStringAsFixed`).

3.  **`subtitle`**:
    *   **Esperado:** `String`
    *   **Recibido:** Posiblemente `null`
    *   **Impacto:** Muestra errores de renderizado o texto vacío.

### Solución Requerida en Backend
Por favor, asegurar que el endpoint de transacciones (`/transacciones` o similar) cumpla con el siguiente contrato y nunca devuelva nulos para estos campos:

```json
{
  "color": 4284572001, // Default: 0xFF9E9E9E (Gris) si no hay color
  "amount": 0.0,       // Default: 0.0 si no hay monto
  "subtitle": "...",   // Default: Cadena vacía o "Sin descripción"
  "date": "YYYY-MM-DD" // Fecha válida
}
```

Si un campo no tiene valor, por favor enviar un valor por defecto en lugar de `null`.
