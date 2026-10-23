# Documento técnico — Asesor de Inscripción de Materias

> **Leyenda.** `[PRELLENADO]` = sección con contenido base que puedes ajustar. `[ESTUDIANTE]` = depende de tu base de conocimientos; debes redactarla tú.
> **Nota:** las 15 secciones siguientes son una propuesta estándar. Si tu rúbrica o la guía de la práctica nombra otras 15, renómbralas/reordénalas; el contenido de apoyo está repartido para que te sirva igual.

---

## Portada `[ESTUDIANTE]`

Institución: ESCOM-IPN · Unidad de aprendizaje: Paradigmas de Programación · Práctica integradora
Título: Asesor de Inscripción de Materias · Alumno(s): ______ · Grupo: ______ · Profesor: ______ · Fecha: ______
URL pública: ______ · Repositorio: ______

## 1. Resumen `[ESTUDIANTE]`

(5–8 líneas: qué problema resuelve, cómo (sistema experto en Prolog), qué se entrega y dónde está desplegado.)

## 2. Introducción y objetivos `[PRELLENADO]`

El proyecto implementa un sistema experto para apoyar la inscripción de materias. El conocimiento (catálogo, requisitos y reglas de inferencia) se expresa en SWI-Prolog; una interfaz web permite al usuario consultarlo sin conocer Prolog.

**Objetivo general:** construir y desplegar una aplicación web cuyo razonamiento sea realizado por un sistema experto en Prolog.
**Objetivos específicos:** (a) modelar el conocimiento del dominio; (b) exponerlo mediante una API JSON; (c) ofrecer una interfaz clara; (d) contenerizar y desplegar el servicio; (e) validar el funcionamiento en producción.

## 3. Descripción del dominio y problema `[ESTUDIANTE]`

(Plan de estudios elegido, número de materias, tipos de requisitos —prerrequisitos simples, alternativas "o", créditos, etc.—, y qué decisiones debe tomar un alumno al inscribirse.)

## 4. Alcance, supuestos y limitaciones `[ESTUDIANTE]`

(Qué cubre y qué no tu base de conocimientos. Supuestos: p. ej. "no se consideran horarios ni cupo".)

## 5. Arquitectura del sistema `[PRELLENADO]`

Arquitectura de un solo servicio (Alternativa C):

```
Navegador (HTML/CSS/JS) → POST /api/consultar (JSON) → servidor SWI-Prolog (library(http/*))
        → predicados de conocimiento.pl → respuesta JSON → Navegador
```

- **Frontend** (`public/`): HTML, CSS y JS puro; solo presenta datos de la API.
- **Servidor** (`prolog/server.pl`): enruta, valida, llama a la base de conocimiento, limita tiempo/resultados y serializa a JSON; también sirve los estáticos.
- **Base de conocimientos** (`prolog/conocimiento.pl`): hechos y reglas.
- **Contenedor** (`Dockerfile`): imagen `swipl:stable`; despliegue en Render/Railway.

Ventajas de la decisión: sin CORS, un solo despliegue, una sola tecnología de servidor.

## 6. Representación del conocimiento: hechos `[ESTUDIANTE]`

(Describe `materia_catalogo/3` y los hechos de requisitos que definiste: forma, ejemplos, por qué esa representación.)

## 7. Reglas e inferencia `[ESTUDIANTE]`

(Explica `disponible/2`, `bloqueada/3`, `ruta/3`, `combinacion/3`, `explicacion/3`: lógica, uso de backtracking, negación por fallo, recursión, cortes. Incluye fragmentos de código y trazas de ejemplo.)

> **Regla de desfase (implementada en `conocimiento.pl`):** si hay una materia sin aprobar del semestre X, no se puede cursar ninguna de semestre mayor a X+2. Predicados: `max_desfase/1`, `atrasadas/3`, `sin_desfase/2`, `puede_cursar/2`, `impedimentos/3`.

## 8. Contrato entre la base de conocimientos y el servidor `[PRELLENADO]`

| Predicado | Significado | Modo de uso |
|---|---|---|
| `materia_catalogo(M, Nombre, Sem)` | Catálogo | Determinista / múltiples hechos |
| `disponible(Apr, M)` | Materias cursables | Backtracking; el servidor recoge hasta 200 soluciones únicas |
| `bloqueada(Apr, M, Faltantes)` | Materias no cursables y qué falta | `once/1` por materia no aprobada |
| `ruta(Apr, Meta, Pasos)` | Ruta por semestres | `once/1`; lista de listas |
| `combinacion(Apr, Max, Ms)` | Combinaciones ≤ Max | Backtracking, hasta 200 |
| `explicacion(M, Apr, Razon)` | Reglas aplicadas (opcional) | `once/1`, hasta 20 materias por consulta |

Los errores (`existence_error`, excepciones, tiempo) se capturan con `catch/3` y `call_with_time_limit/2` y se traducen a JSON con el código HTTP adecuado.

## 9. API y servidor `[PRELLENADO]`

Rutas: `GET /health`, `GET /api/materias`, `POST /api/consultar`. Cuerpo: `{"tipo","aprobadas","max","meta"}`. Respuesta: `{"ok","tipo","total","truncado","mensaje","resultados","explicacion"}`. Códigos: 200, 400, 404, 405, 411, 413, 500, 503, 504. Ejemplos completos en el `README.md`.

Pipeline de una consulta: leer cuerpo (límite 64 KB) → validar → resolver con el predicado correspondiente (≤ 5 s) → enriquecer con nombres del catálogo → pedir explicaciones → serializar.

## 10. Interfaz de usuario `[PRELLENADO]`

Selección múltiple de aprobadas agrupada por semestre con buscador y botones de limpieza; selector de tipo; campos condicionales (`meta` solo para ruta, `max` solo para combinaciones); indicador de carga; tarjetas, rutas por semestre y chips de faltantes; panel "¿Por qué?"; mensajes para sin resultados, datos insuficientes, valores inválidos, errores del servidor y de red; nueva consulta sin recargar. Diseño responsivo y accesible (etiquetas, `aria-live`, foco visible, modo oscuro). Agrega capturas de pantalla aquí `[ESTUDIANTE]`.

## 11. Seguridad y validación `[PRELLENADO]`

- Sin construcción/ejecución de código desde texto del usuario; IDs validados contra el catálogo y comparados como cadenas (no se crean átomos nuevos).
- Lista blanca de `tipo`; `max` entero 1–10; `aprobadas` lista de IDs válidos sin duplicados; `meta` obligatoria solo en `ruta`.
- Límites: 200 resultados, 5 s por consulta, 64 KB de cuerpo, 200 aprobadas.
- Frontend con `textContent`; solo se publica `public/`; contenedor con usuario sin privilegios.

## 12. Contenerización y despliegue `[PRELLENADO + ESTUDIANTE]`

Dockerfile basado en `swipl:stable`, copia `prolog/` y `public/`, expone 8080 y arranca `swipl prolog/server.pl` (lee `PORT`, enlaza `0.0.0.0`). Procedimiento en `docs/despliegue.md`. Registra aquí `[ESTUDIANTE]`: plataforma elegida, URL, fecha, incidencias y cómo las resolviste.

## 13. Pruebas y resultados `[ESTUDIANTE]`

Adjunta la tabla de `tests/casos_prueba.md` llena (10 casos + 8 escenarios de producción), la salida de `tests/probar_api.sh` y evidencias (capturas).

## 14. Uso de herramientas de IA `[ESTUDIANTE]`

Resumen de `docs/declaracion_uso_ia.md`: IA usada en servidor, interfaz, Docker, despliegue, documentación y `conocimiento.pl` (catálogo del mapa curricular IIA 2020 y seriación propuesta, a verificar). Describe cómo verificaste y entendiste el código generado.

## 15. Conclusiones, limitaciones y trabajo futuro `[ESTUDIANTE]`

(Aprendizajes sobre el paradigma lógico, limitaciones —p. ej. sin horarios/cupos, explosión combinatoria en combinaciones— y mejoras: créditos máximos, optativas, persistencia de historial académico, etc.)

## Referencias y anexos

- SWI-Prolog Manual: <https://www.swi-prolog.org/pldoc/doc_for?object=manual>
- HTTP libraries de SWI-Prolog: <https://www.swi-prolog.org/pldoc/man?section=httpserver>
- Documentación de Docker y de Render.
- Anexos: código de `conocimiento.pl`, capturas, enlace al video.
