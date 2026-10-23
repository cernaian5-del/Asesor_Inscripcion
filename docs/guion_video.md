# Guion de video (5 a 8 minutos)

Graba pantalla + voz. Antes de grabar: abre la URL pública unos minutos antes (arranque en frío), prepara la terminal y el repositorio. Tiempos orientativos (total ≈ 7:00).

| Tiempo | Escena | Qué mostrar | Qué decir (guía) |
|---|---|---|---|
| 0:00–0:30 | **Presentación** | Portada / README | Nombre, materia, grupo; el problema: elegir materias según requisitos; la solución: un sistema experto en Prolog con interfaz web. |
| 0:30–1:30 | **Arquitectura** | Diagrama del README | Navegador → API JSON → servidor SWI-Prolog → `conocimiento.pl` → JSON. Un solo servicio, sin CORS, desplegado con Docker. El servidor no razona: solo valida y traduce. |
| 1:30–3:30 | **Base de conocimientos** | `conocimiento.pl` | Hechos del catálogo y requisitos; reglas de `disponible`, `bloqueada`, `ruta`, `combinacion`, `explicacion`; backtracking y negación por fallo. Ejecuta una consulta en el intérprete (`?- disponible([...], M).`). |
| 3:30–4:00 | **Servidor y seguridad** | `server.pl` | Rutas, validación con lista blanca, IDs comparados contra el catálogo (sin `atom_to_term`), límites (200 resultados, 5 s) y `catch/3` para errores controlados. |
| 4:00–5:30 | **Demostración en producción** | URL pública en el navegador | Consulta válida con "¿Por qué?"; otra combinación; bloqueadas con faltantes; ruta por semestres; combinaciones (múltiples soluciones); nueva consulta sin recargar. |
| 5:30–6:15 | **Casos límite** | Navegador + terminal (`curl`) | Ruta sin meta (datos insuficientes); `max` inválido; ID inexistente → 400; sin resultados. Corre `./tests/probar_api.sh <URL>`. Acceso externo desde el celular. |
| 6:15–6:45 | **Docker y despliegue** | `Dockerfile`, panel de Render, `/health` | Imagen `swipl:stable`, `PORT`, `0.0.0.0`, healthcheck; commits en GitHub. |
| 6:45–7:15 | **Uso de IA y cierre** | `declaracion_uso_ia.md` | IA en servidor, interfaz, Docker, despliegue, docs también en `conocimiento.pl` (catálogo, seriación y reglas, que verifiqué). Conclusiones, limitaciones y mejoras. |

## Lista de verificación previa

- [ ] URL pública funcionando y "despierta".
- [ ] Tabla de `tests/casos_prueba.md` llena.
- [ ] Resolución de pantalla ≥ 1080p; texto legible; sin datos personales ni secretos visibles.
- [ ] Audio claro; duración entre 5 y 8 minutos.
- [ ] Enlace del video y del repositorio incluidos en el documento técnico.
