# Guía de despliegue

## 0. Antes de desplegar

1. Completa `prolog/conocimiento.pl` y pruébalo localmente (`swipl prolog/server.pl`).
2. Verifica el contenedor: `docker build -t asesor-inscripcion .` y `docker run --rm -p 8080:8080 asesor-inscripcion`; abre <http://localhost:8080> y ejecuta `./tests/probar_api.sh http://localhost:8080`.
3. Sube el repo a GitHub (ver `docs/git_commits.md`).

## 1. Render (Web Service tipo Docker)

1. Entra a <https://render.com> e inicia sesión con GitHub.
2. **New + → Web Service** → *Build and deploy from a Git repository* → elige el repositorio (autoriza el acceso si lo pide).
3. Configura:
   - **Name**: `asesor-inscripcion` (define la URL `https://asesor-inscripcion.onrender.com`).
   - **Language / Runtime**: **Docker** (Render detecta el `Dockerfile` en la raíz).
   - **Branch**: `main`. **Root Directory**: vacío.
   - **Instance Type**: *Free* (suficiente para la práctica).
4. **Advanced**:
   - **Health Check Path**: `/health`.
   - **Environment Variables**: no es obligatorio agregar nada; Render inyecta `PORT` automáticamente y `server.pl` lo lee. (Opcional: `LANG=C.UTF-8`, ya incluido en el Dockerfile.)
   - **Auto-Deploy**: *On Commit* para redeploy en cada `git push`.
5. **Create Web Service**. Observa los *Logs*; el despliegue termina cuando aparece `Asesor de Inscripcion escuchando en http://0.0.0.0:<puerto>` y el estado cambia a *Live*.
6. Prueba: `./tests/probar_api.sh https://TU-APP.onrender.com`.

## 2. Alternativa: Railway

1. <https://railway.app> → **New Project → Deploy from GitHub repo** → elige el repo.
2. Railway detecta el `Dockerfile` y construye con él.
3. En **Settings → Networking → Generate Domain** para obtener la URL pública.
4. En **Settings → Deploy → Healthcheck Path** pon `/health`.
5. Railway inyecta `PORT`; no hace falta configurarlo.

## 3. Diagnóstico de errores comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| Render: "No open ports detected" / el deploy no pasa a *Live* | El servidor no escucha en `0.0.0.0:$PORT` | `server.pl` ya lee `PORT` y enlaza `0.0.0.0`. Revisa que no cambiaste `iniciar/1` y que el CMD sea `swipl prolog/server.pl`. Mira los logs por errores de carga. |
| `Port scan timeout` | La base de conocimiento tarda demasiado en cargar o hay un error de sintaxis que detiene el arranque | Corre `swipl prolog/server.pl` local y corrige advertencias/errores de `conocimiento.pl`. |
| Falla el *build* ("failed to solve", "pull access denied") | Typo en `FROM`, `Dockerfile` no está en la raíz, o rutas `COPY` incorrectas | Verifica `FROM swipl:stable`, que existan `prolog/` y `public/` en el repo (no en `.gitignore`/`.dockerignore`). |
| `/api/materias` devuelve 503 "no implementa el predicado…" | Falta un predicado del contrato en `conocimiento.pl` | Impleméntalo (o define al menos `materia_catalogo/3`). |
| Acentos con "�" | Codificación no UTF-8 | El Dockerfile ya fija `LANG=C.UTF-8`; guarda `conocimiento.pl` como UTF-8. |
| Respuesta 504 / "consulta cancelada" | La consulta supera 5 s (explosión combinatoria) | Reduce `max`, optimiza la regla o añade cortes (`!`)/`once/1`. |
| Primera carga muy lenta (30–60 s) y a veces `502/503` | **Arranque en frío**: el plan gratuito de Render duerme la app tras ~15 min sin tráfico | Espera y recarga; abre la URL unos minutos antes de la demo/video; la interfaz muestra mensaje y botón "Reintentar". |
| Cambios no aparecen | Despliegue no se disparó o caché del navegador | Revisa *Events* en Render, haz `git push`, recarga con Ctrl+F5. |
| Funciona en local pero no en Render | `conocimiento.pl` depende de archivos que no están en el repo | Todo debe estar en `prolog/`; revisa mayúsculas/minúsculas en nombres (Linux distingue). |
| Con Docker local: "port is already allocated" | El 8080 está ocupado | `docker run -p 9090:8080 …` y abre <http://localhost:9090>. |

### Dónde mirar

- Render: pestaña **Logs** (stdout/stderr del contenedor) y **Events** (historial de deploys).
- Local: la terminal donde corre `swipl`. Los errores internos de la API se imprimen ahí; al cliente solo llega un mensaje genérico (HTTP 500).
- Prueba aislada del servidor: `curl -i https://TU-APP.onrender.com/health`.

## 4. Consideraciones del plan gratuito

- La instancia se suspende por inactividad; el primer request la reactiva (arranque en frío).
- Recursos limitados: evita consultas que generen miles de combinaciones (el servidor ya corta en 200 resultados y 5 s).
- Para la entrega, haz una visita previa a la URL y toma las capturas con la app ya despierta.
