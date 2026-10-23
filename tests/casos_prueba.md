# Casos de prueba

Llena las columnas **Resultado obtenido** y **¿Pasó?** al ejecutar. Sustituye `<M1>`, `<M2>`… por IDs reales de tu `materia_catalogo/3`.

Ejecuta primero `./tests/probar_api.sh <URL>` para la verificación automática de la API y luego repite los casos en la interfaz.

## A. Diez casos de prueba

| # | Caso | Entrada | Resultado esperado | Resultado obtenido | ¿Pasó? |
|---|------|---------|--------------------|--------------------|--------|
| 1 | Disponibles con aprobadas | `tipo=disponibles`, aprobadas: `<M1>, <M2>` | HTTP 200; lista de materias cuyos requisitos están cubiertos | | |
| 2 | Disponibles sin aprobadas | `tipo=disponibles`, aprobadas: (vacío) | HTTP 200; solo materias sin requisitos | | |
| 3 | Bloqueadas con faltantes | `tipo=bloqueadas`, aprobadas: `<M1>` | HTTP 200; cada materia con sus faltantes | | |
| 4 | Ruta a una meta | `tipo=ruta`, aprobadas: (vacío), meta: `<MetaLejana>` | HTTP 200; materias agrupadas por semestre en orden válido | | |
| 5 | Ruta con meta ya disponible | `tipo=ruta`, aprobadas: `<Req>`, meta: `<MetaCercana>` | HTTP 200; ruta corta / mensaje coherente | | |
| 6 | Combinaciones con máximo | `tipo=combinaciones`, aprobadas: `<M1>`, max: 3 | HTTP 200; cada combinación con ≤ 3 materias | | |
| 7 | Sin coincidencias | Todas las materias aprobadas (o ninguna disponible) | HTTP 200; `total=0` y mensaje claro | | |
| 8 | Ruta sin meta | `tipo=ruta`, sin meta | HTTP 400; "requiere el campo meta" | | |
| 9 | Valor de max inválido | `tipo=combinaciones`, max: 0 / 11 / "abc" | HTTP 400; mensaje de rango | | |
| 10 | ID inexistente / inyección | aprobadas: `no_existe` y `x), halt, foo(` | HTTP 400; no se ejecuta nada | | |

## B. Ocho escenarios de validación en producción (URL pública)

| # | Escenario | Procedimiento | Resultado esperado | Resultado obtenido | ¿Pasó? |
|---|-----------|---------------|--------------------|--------------------|--------|
| 1 | Consulta válida | Elegir aprobadas, tipo "disponibles", Consultar | Tarjetas de materias + panel "¿Por qué?" | | |
| 2 | Otra combinación de datos | Cambiar aprobadas y tipo (p. ej. "bloqueadas") | Resultados distintos y coherentes con la base | | |
| 3 | Sin coincidencias | Consulta que no produce soluciones | Mensaje informativo, sin error | | |
| 4 | Datos incompletos | Tipo "ruta" sin materia meta | Aviso de datos insuficientes; no se envía la petición | | |
| 5 | Valores no válidos | Máximo = 0, 11 o vacío; o petición con `curl` y datos erróneos | Mensaje de validación (UI) / HTTP 400 (API) | | |
| 6 | Múltiples soluciones | `combinaciones` con varias materias disponibles | Varias opciones listadas (backtracking) | | |
| 7 | Nueva consulta sin recargar | Pulsar "Nueva consulta" y consultar otra vez | Estado limpio; nuevo resultado sin recargar la página | | |
| 8 | Acceso externo | Abrir la URL pública desde otro dispositivo/red (celular con datos móviles) | La app carga y responde; `/health` devuelve 200 | | |

**Notas de la prueba:** fecha, URL probada, navegador/dispositivo, observaciones (p. ej. tiempo del arranque en frío en el plan gratuito).
