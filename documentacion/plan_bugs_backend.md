# Plan de Resolución de Bugs y Refactorización - Backend

## Objetivo
Corregir errores lógicos, de seguridad y de consistencia en el backend Ruby/Sinatra, estandarizando la arquitectura para facilitar la integración con el frontend.

## Bugs y Mejoras Identificados

### 1. Inconsistencia en Formatos de Respuesta (Prioridad Alta)
*   **Problema**: Actualmente conviven dos formatos de respuesta.
    *   *Legacy*: `{ status: 'ok', message: '...', [resource]: ... }`
    *   *Nuevo*: `{ success: true, message: '...', data: ..., error: ... }`
    *   Esto complica el parseo en el frontend (Flutter).
*   **Solución**: Refactorizar **TODOS** los controladores para usar el helper `GenericResponse`.
    *   Controladores afectados: `Cuentas`, `Chat`, `Perfil`, `Login`, `Registro`, `Dashboard`, `TwoFactor`, `ResetPassword`, `Eliminar`.

### 2. Filtrado de Datos por Usuario (Prioridad Alta)
*   **Problema**: Algunos endpoints (ej. listado de cuentas) podrían no estar filtrando correctamente por `usuario_id`, exponiendo datos de otros usuarios o mezclándolos.
*   **Solución**:
    *   Revisar todas las consultas `SELECT` en los modelos/controladores.
    *   Asegurar que **SIEMPRE** exista una cláusula `WHERE idUsuario = ?`.
    *   Estandarizar la recepción del `user_id` (Query param para GET/DELETE, Body para POST/PUT) mientras se implementa JWT.

### 3. Seguridad: Validación de Propiedad (Prioridad Alta)
*   **Problema**: En endpoints de edición/eliminación (`PUT`, `DELETE`), se debe verificar que el recurso (ej. Cuenta ID 5) pertenezca realmente al usuario que intenta modificarlo.
*   **Solución**:
    *   Antes de ejecutar `UPDATE` o `DELETE`, hacer una consulta `SELECT` verificando `id` y `idUsuario`.
    *   Si no coincide, devolver `403 Forbidden` o `404 Not Found`.

### 4. Manejo de Errores y Validaciones (Prioridad Media)
*   **Problema**:
    *   Código repetitivo `begin/rescue` en cada método.
    *   Validaciones de datos de entrada (nulos, tipos incorrectos) manuales y dispersas.
*   **Solución**:
    *   Usar `GenericResponse` para manejar excepciones de forma uniforme.
    *   Validar presencia de campos obligatorios al inicio del controlador y devolver `400 Bad Request` con mensaje claro si faltan.

### 5. Inyección SQL (Prioridad Crítica)
*   **Problema**: Verificar si algún controlador legacy concatena strings en las queries en lugar de usar parámetros (`?`).
*   **Solución**:
    *   Auditar todo el código en `models/` y `controllers/`.
    *   Reemplazar cualquier interpolación `#{var}` en SQL por `?` y pasar los argumentos en el array de `execute`.

## Plan de Ejecución

### Fase 1: Cuentas y Transacciones (Núcleo)
1.  [x] Refactorizar `CuentasController`: Usar `GenericResponse`, validar `user_id`.
2.  [ ] Refactorizar `RegistrosController` (Ingresos/Gastos): Validar que la cuenta pertenezca al usuario.

### Fase 2: Usuarios y Autenticación
3.  [ ] Refactorizar `LoginController` y `RegistroController`: Estandarizar respuestas.
4.  [ ] Refactorizar `PerfilController`: Asegurar que solo se edite el perfil propio.

### Fase 3: Funcionalidades Extra
5.  [ ] Refactorizar `ChatController`.
6.  [ ] Refactorizar `DashboardController`.
7.  [ ] Refactorizar `TwoFactor` y `ResetPassword`.

### Fase 4: Limpieza
8.  [ ] Eliminar código muerto o comentado.
9.  [ ] Unificar modelos si hay duplicidad.
