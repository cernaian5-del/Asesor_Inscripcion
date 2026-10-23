# Secuencia de commits sugerida

Crea primero un repositorio vacío en GitHub (sin README) y reemplaza `TU_USUARIO`.

```bash
git init -b main
git config user.name "Tu Nombre"
git config user.email "tu_correo@ejemplo.com"
```

**1. Estructura inicial**

```bash
git add .gitignore .dockerignore README.md prolog/conocimiento.pl
git commit -m "chore: estructura inicial del repositorio y esqueleto de conocimiento.pl"
```

**2. Servidor**

```bash
git add prolog/server.pl
git commit -m "feat(server): API JSON, validación de entrada, límites de tiempo/resultados y archivos estáticos"
```

**3. Interfaz**

```bash
git add public/
git commit -m "feat(ui): interfaz responsiva en HTML/CSS/JS para consultar al sistema experto"
```

**4. Docker**

```bash
git add Dockerfile .dockerignore
git commit -m "build(docker): imagen basada en swipl:stable con usuario sin privilegios"
```

**5. Documentación**

```bash
git add README.md docs/
git commit -m "docs: README, guía de despliegue, documento técnico, declaración de IA y guion de video"
```

**6. Pruebas**

```bash
git add tests/
git commit -m "test: plantilla de casos de prueba y script de pruebas con curl"
```

**7. Base de conocimientos (catálogo IIA 2020, seriación y reglas)**

```bash
git add prolog/conocimiento.pl
git commit -m "feat(kb): catálogo IIA 2020, seriación y reglas de inferencia"
```

**Publicar**

```bash
git remote add origin https://github.com/TU_USUARIO/asesor-inscripcion.git
git push -u origin main
```

Cada cambio posterior: `git add -p` → `git commit -m "tipo: descripción"` → `git push` (Render redespliega solo).

> Consejo: antes del primer commit confirma con `git status` que no se suban `.env`, logs ni archivos del sistema.
