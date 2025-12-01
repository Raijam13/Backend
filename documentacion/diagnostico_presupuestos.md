# Diagnóstico: Falla en Presupuestos

## Problema Principal
El controlador `PresupuestosController` está fallando porque hay un **desajuste entre los requerimientos documentados y el esquema real de la base de datos**.

## Análisis Detallado

### 1. Campo `monto` vs `monto_total`
**Requerimientos (`backend_requirements.md`):**
```json
{
  "monto_total": 1500.00
}
```

**Base de Datos Real (`Presupuesto` table):**
```sql
"monto" REAL NOT NULL
```

**Controlador Actual (`presupuestos_controller.rb`):**
```ruby
monto: body["monto"]
```

**Conclusión:** El controlador usa `monto` (correcto según BD), pero los requerimientos especifican `monto_total`. Si el frontend envía `monto_total`, el backend no lo encontrará.

### 2. Campo `fecha_inicio` (FALTA en BD)
**Requerimientos:**
```json
{
  "fecha_inicio": "2023-11-01"
}
```

**Base de Datos Real:**
No existe columna `fecha_inicio` en la tabla `Presupuesto`.

**Conclusión:** Si el frontend envía `fecha_inicio`, será ignorado. Si es obligatorio, debería agregarse a la BD.

### 3. Campo `user_id` vs `idUsuario`
**Requerimientos:**
```json
{
  "user_id": 1
}
```

**Controlador:**
```ruby
idUsuario: body["user_id"]
```

**Conclusión:** Mapeo correcto (snake_case a camelCase).

## Solución Propuesta

### Opción A: Ajustar el Controlador a los Requerimientos
- Cambiar `body["monto"]` → `body["monto_total"]` en el controlador
- Agregar columna `fecha_inicio` a la tabla `Presupuesto` (migración)
- O ignorar `fecha_inicio` si no es crítico

### Opción B: Actualizar los Requerimientos
- Cambiar la documentación para reflejar el esquema real:
  - `monto` en lugar de `monto_total`
  - Eliminar `fecha_inicio` si no es necesario

## Recomendación
**Opción A parcial**: Soportar ambos nombres de campo (`monto` y `monto_total`) en el controlador para compatibilidad, y hacer `fecha_inicio` opcional.

```ruby
# En el controlador:
monto: body["monto_total"] || body["monto"],
# Ignorar fecha_inicio por ahora si la BD no la tiene
```
