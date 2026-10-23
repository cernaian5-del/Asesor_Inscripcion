# Asesor de Inscripción de Materias

Aplicación web cuyo **motor de razonamiento es un sistema experto en SWI-Prolog**. Dado el conjunto de materias aprobadas, responde qué materias se pueden cursar, cuáles están bloqueadas y por qué, qué ruta seguir hacia una materia meta y qué combinaciones de inscripción son posibles.

Práctica integradora — ESCOM-IPN, Paradigmas de Programación.

## Arquitectura

Un único servicio SWI-Prolog sirve la API JSON y los archivos estáticos: sin CORS y con un solo despliegue.

```
 ┌────────────┐   GET /, /app.js, /style.css    ┌──────────────────────────────────────────┐
 │            │ ───────────────────────────────▶│  Servidor SWI-Prolog (library(http/*))   │
 │ Navegador  │                                 │                                          │
 │ HTML/CSS/JS│   POST /api/consultar (JSON)    │  server.pl: valida → llama → a JSON      │
 │ (vanilla)  │ ───────────────────────────────▶│        │                                 │
 │            │◀─────────────────────────────── │        ▼                                 │
 └────────────┘        respuesta JSON           │  conocimiento.pl: hechos y reglas        │
                                                └──────────────────────────────────────────┘
                                          (todo dentro de un contenedor Docker)
```

- `server.pl` **no razona**: valida la entrada, invoca los predicados de `conocimiento.pl` y convierte el resultado a JSON.
- El frontend **no simula inferencia**: todo lo que muestra viene de la API.

## Estructura del repositorio

```
.
├── prolog/
│   ├── conocimiento.pl      # Base de conocimientos (la escribe el estudiante)
│   └── server.pl            # Servidor HTTP, validación, conversión a JSON
├── public/
│   ├── index.html
│   ├── style.css
│   └── app.js
├── tests/
│   ├── casos_prueba.md      # Plantilla: 10 casos + 8 escenarios de producción
│   └── probar_api.sh        # Pruebas con curl (local o URL pública)
├── docs/
│   ├── documento_tecnico.md
│   ├── declaracion_uso_ia.md
│   ├── guion_video.md
│   ├── despliegue.md        # Render / Railway + diagnóstico de errores
│   └── git_commits.md       # Secuencia de commits sugerida
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

## Contrato con `conocimiento.pl`

Las materias son **átomos**. `server.pl` llama a estos predicados (firmas fijas):

| Predicado | Descripción |
|---|---|
| `materia_catalogo(Materia, Nombre, Semestre)` | Hechos del catálogo (puebla la interfaz y valida IDs). |
| `disponible(Aprobadas, Materia)` | Backtracking: una solución por materia que puede cursarse. |
| `bloqueada(Aprobadas, Materia, Faltantes)` | `Faltantes`: lista de átomos. |
| `ruta(Aprobadas, Meta, Pasos)` | `Pasos`: lista de listas (una por semestre). |
| `combinacion(Aprobadas, Max, Materias)` | Backtracking: lista de longitud ≤ `Max`. |
| `explicacion(Materia, Aprobadas, Razon)` | *Opcional.* Lista de átomos/cadenas con las reglas aplicadas. |

Si un predicado no existe o lanza un error, el servidor responde con JSON de error controlado (no se cae).

## Ejecución local

### Sin Docker

Requiere [SWI-Prolog](https://www.swi-prolog.org/Download.html) 9.x.

```bash
swipl prolog/server.pl          # escucha en http://0.0.0.0:8080
PORT=3000 swipl prolog/server.pl   # otro puerto (Windows PowerShell: $env:PORT=3000; swipl prolog\server.pl)
```

Abre <http://localhost:8080>. En Windows, si los acentos se ven mal, ejecuta antes `chcp 65001`.

### Con Docker

```bash
docker build -t asesor-inscripcion .
docker run --rm -p 8080:8080 asesor-inscripcion
# otro puerto del anfitrión:  docker run --rm -e PORT=9000 -p 9000:9000 asesor-inscripcion
```

### Pruebas rápidas

```bash
./tests/probar_api.sh http://localhost:8080
./tests/probar_api.sh https://TU-APP.onrender.com
```

## API

| Método y ruta | Descripción |
|---|---|
| `GET /health` | Healthcheck → `{"status":"ok","conocimiento":true}` |
| `GET /api/materias` | Catálogo para poblar la interfaz |
| `POST /api/consultar` | Consulta al sistema experto |

Códigos de error (siempre JSON `{"ok":false,"error":"..."}`): `400` validación, `404` ruta de API inexistente, `405` método no permitido, `411/413` cuerpo sin longitud/demasiado grande, `500` error interno controlado, `503` base de conocimiento incompleta (predicado inexistente), `504` consulta cancelada por tiempo (5 s).

### Ejemplos

`GET /api/materias`

```json
{"materias":[{"id":"calculo","nombre":"Cálculo","semestre":1},
             {"id":"calculo2","nombre":"Cálculo 2","semestre":2}]}
```

`POST /api/consultar` — disponibles

```json
// petición
{"tipo":"disponibles","aprobadas":["calculo"]}
// respuesta
{"ok":true,"tipo":"disponibles","total":1,"truncado":false,"mensaje":"",
 "resultados":[{"id":"calculo2","nombre":"Cálculo 2","semestre":2}],
 "explicacion":[{"materia":{"id":"calculo2","nombre":"Cálculo 2","semestre":2},
                 "razon":["Requiere Cálculo","Cálculo aprobada"]}]}
```

Bloqueadas

```json
{"tipo":"bloqueadas","aprobadas":[]}
// resultados: [{"id":"fisica","nombre":"Física","semestre":3,
//               "faltantes":[{"id":"calculo2","nombre":"Cálculo 2","semestre":2}]}]
```

Ruta (`meta` obligatoria)

```json
{"tipo":"ruta","aprobadas":[],"meta":"fisica"}
// resultados: [{"semestre":1,"materias":[...]},{"semestre":2,"materias":[...]}]
```

Combinaciones (`max` entre 1 y 10, por defecto 5)

```json
{"tipo":"combinaciones","aprobadas":["calculo"],"max":3}
// resultados: [{"cantidad":2,"materias":[...]}, ...]
```

Error de validación

```json
{"ok":false,"error":"La consulta \"ruta\" requiere el campo \"meta\" (materia objetivo)."}
```

Los resultados se limitan a 200 (`"truncado":true` si se recortó) y cada consulta tiene un límite de 5 s.

## Regla de desfase

Además de los prerrequisitos, `conocimiento.pl` aplica esta regla: **si tienes sin aprobar una materia del semestre X, no puedes cursar ninguna materia con más de 2 semestres de diferencia** (semestre mayor a X+2). Se calcula respecto a la materia pendiente más atrasada y el límite se cambia en `max_desfase/1`. Efecto en las consultas:

- `disponibles`: excluye las materias que violan el desfase.
- `bloqueadas`: en `faltantes` aparecen los prerrequisitos pendientes **y** las materias atrasadas que causan el bloqueo.
- `ruta`: incluye en los semestres de la ruta las materias atrasadas que hay que regularizar antes de llegar a la meta.
- `combinaciones` y "¿Por qué?": respetan y explican la regla.

## Seguridad

- No se construye ni evalúa código Prolog con texto del usuario (sin `atom_to_term`/`term_to_atom`): los IDs se comparan contra los átomos de `materia_catalogo/3`.
- Lista blanca de `tipo`, `max` entero 1–10, `aprobadas` sin duplicados, tamaño de cuerpo limitado.
- El frontend usa `textContent` (no `innerHTML`); solo se sirve el directorio `public/`.
- El contenedor corre con un usuario sin privilegios.

## Despliegue

Resumen para **Render** (guía completa en [`docs/despliegue.md`](docs/despliegue.md)):

1. Sube el repositorio a GitHub.
2. En Render: **New → Web Service** → conecta el repo → *Runtime/Language*: **Docker**.
3. *Health Check Path*: `/health`. No hace falta definir `PORT` (Render lo inyecta).
4. Despliega y prueba `https://TU-APP.onrender.com`.

## Créditos y uso de IA

El servidor, la interfaz, Docker, el despliegue, la documentación y la base de conocimientos `conocimiento.pl` se elaboraron con apoyo de IA. **La seriación (prerrequisitos) es una propuesta: el mapa curricular no la incluye, verifícala con el plan oficial.** Ver [`docs/declaracion_uso_ia.md`](docs/declaracion_uso_ia.md).
