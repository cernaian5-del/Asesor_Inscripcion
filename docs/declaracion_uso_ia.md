# Declaración de uso de inteligencia artificial

**Proyecto:** Asesor de Inscripción de Materias · ESCOM-IPN · Paradigmas de Programación
**Alumno(s):** ____________________  **Boleta(s):** ____________  **Grupo:** ______  **Fecha:** ____________

## 1. Declaración

Declaro que utilicé una herramienta de inteligencia artificial generativa (**Claude, de Anthropic**) **para apoyar las siguientes partes del proyecto:

| Componente | Archivos | Uso de IA |
|---|---|---|
| Servidor HTTP, validación y conversión a JSON | `prolog/server.pl` | Sí |
| Interfaz web | `public/index.html`, `style.css`, `app.js` | Sí |
| Contenerización | `Dockerfile`, `.dockerignore` | Sí |
| Despliegue y control de versiones | `docs/despliegue.md`, `docs/git_commits.md`, `.gitignore` | Sí |
| Documentación y plantillas | `README.md`, `docs/*`, `tests/*` | Sí (plantillas y esqueletos) |
| Base de conocimientos | `prolog/conocimiento.pl` | **Sí** (catálogo tomado del mapa curricular, reglas y seriación propuestas por la IA) |

Declaro expresamente que **la IA sí se utilizó para escribir `conocimiento.pl`**: generó el catálogo a partir del mapa curricular IIA 2020, la **seriación supuesta** (el mapa no la incluye) y las reglas `disponible/2`, `bloqueada/3`, `ruta/3`, `combinacion/3` y `explicacion/3`. Yo verifiqué el catálogo contra el mapa y la seriación contra el plan oficial, y ajusté: ____________________ (completa).

## 2. Verificación y responsabilidad

- Revisé, ejecuté y probé el código generado (local y en producción) y entiendo su funcionamiento.
- Las secciones del documento técnico que explican mi base de conocimientos las redacté yo después de entender el código.
- Asumo la responsabilidad de todo el contenido entregado.

## 3. Registro de uso (completa)

| Fecha | Herramienta / modelo | Propósito | Resultado y ajustes que hice |
|---|---|---|---|
| | Claude | Generar servidor, interfaz, Docker y documentación | |
| | | | |

## 4. Firma

Nombre y firma: ______________________________   Fecha: ______________
