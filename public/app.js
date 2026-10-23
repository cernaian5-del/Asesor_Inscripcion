/* app.js — Interfaz del Asesor de Inscripción de Materias.
 * NO hay lógica de inferencia aquí: todo resultado proviene de la API
 * (servidor SWI-Prolog). Este archivo solo valida campos básicos, hace fetch
 * y pinta la respuesta. Se usa textContent (nunca innerHTML) para evitar XSS.
 */
(function () {
  "use strict";

  const API = { materias: "/api/materias", consultar: "/api/consultar" };
  const TIMEOUT_MS = 20000;   // el plan gratuito puede tardar en "despertar"

  const AYUDAS = {
    disponibles: "Lista las materias que ya cumplen todos sus requisitos con lo que aprobaste.",
    bloqueadas: "Muestra las materias que aún no puedes cursar y qué requisitos te faltan.",
    ruta: "Calcula, semestre por semestre, qué cursar para llegar a la materia meta.",
    combinaciones: "Propone grupos de materias que puedes inscribir juntas (hasta el máximo indicado)."
  };

  const $ = (id) => document.getElementById(id);
  const ui = {
    banner: $("banner"), lista: $("lista-materias"), buscador: $("buscador"),
    contador: $("contador"), limpiar: $("btn-limpiar-sel"),
    form: $("form"), tipo: $("tipo"), ayudaTipo: $("ayuda-tipo"),
    campoMeta: $("campo-meta"), meta: $("meta"),
    campoMax: $("campo-max"), max: $("max"),
    btn: $("btn-consultar"), btnTexto: $("btn-texto"), spinner: document.querySelector(".spinner"),
    reiniciar: $("btn-reiniciar"),
    estado: $("estado"), resultados: $("resultados"),
    porque: $("panel-porque"), porqueCont: $("porque-contenido")
  };

  let catalogo = [];                 // [{id, nombre, semestre}]
  let porId = new Map();
  let abortActual = null;

  /* ---------- utilidades DOM ---------- */
  function el(tag, props, ...hijos) {
    const e = document.createElement(tag);
    if (props) for (const [k, v] of Object.entries(props)) {
      if (k === "class") e.className = v;
      else if (k === "text") e.textContent = v;
      else e.setAttribute(k, v);
    }
    for (const h of hijos) if (h != null) e.append(h);
    return e;
  }
  function vaciar(n) { while (n.firstChild) n.removeChild(n.firstChild); }
  function normalizar(s) {
    return String(s).normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  }
  function nombreDe(id) { const m = porId.get(id); return m ? m.nombre : String(id); }

  function mostrarEstado(tipo, texto, conBoton) {
    ui.estado.hidden = false;
    ui.estado.className = "aviso aviso-" + tipo;
    ui.estado.textContent = texto;
    if (conBoton) ui.estado.append(conBoton);
  }
  function ocultarEstado() { ui.estado.hidden = true; ui.estado.textContent = ""; }

  /* ---------- fetch con manejo de errores ---------- */
  async function pedir(url, opciones) {
    const ctrl = new AbortController();
    abortActual = ctrl;
    const t = setTimeout(() => ctrl.abort(), TIMEOUT_MS);
    let resp;
    try {
      resp = await fetch(url, { ...opciones, signal: ctrl.signal });
    } catch (e) {
      const err = new Error(e.name === "AbortError"
        ? "El servidor tardó demasiado en responder. Si es el primer acceso, el servicio gratuito puede estar “despertando”; intenta de nuevo en unos segundos."
        : "No se pudo conectar con el servidor. Revisa tu conexión a internet e inténtalo otra vez.");
      err.red = true; throw err;
    } finally { clearTimeout(t); }

    let datos = null;
    try { datos = await resp.json(); } catch (_) { /* no era JSON */ }
    if (!resp.ok || (datos && datos.ok === false)) {
      const msg = datos && datos.error
        ? datos.error
        : "El servidor respondió con un error inesperado (HTTP " + resp.status + ").";
      const err = new Error(msg); err.status = resp.status; throw err;
    }
    if (datos === null) throw new Error("La respuesta del servidor no tiene el formato esperado.");
    return datos;
  }

  /* ---------- catálogo ---------- */
  async function cargarCatalogo() {
    vaciar(ui.lista);
    ui.lista.append(el("p", { class: "cargando", text: "Cargando catálogo…" }));
    ui.banner.hidden = true;
    try {
      const d = await pedir(API.materias);
      catalogo = Array.isArray(d.materias) ? d.materias : [];
      porId = new Map(catalogo.map((m) => [m.id, m]));
      if (!catalogo.length) throw new Error("El catálogo de materias está vacío.");
      pintarCatalogo();
      llenarMeta();
    } catch (e) {
      vaciar(ui.lista);
      ui.lista.append(el("p", { class: "cargando", text: "No se pudo cargar el catálogo." }));
      ui.banner.hidden = false;
      ui.banner.textContent = e.message + " ";
      const b = el("button", { type: "button", class: "btn btn-sec", text: "Reintentar" });
      b.addEventListener("click", cargarCatalogo);
      ui.banner.append(b);
    }
  }

  function pintarCatalogo() {
    vaciar(ui.lista);
    const grupos = new Map();
    for (const m of catalogo) {
      const s = Number.isInteger(m.semestre) ? m.semestre : 0;
      if (!grupos.has(s)) grupos.set(s, []);
      grupos.get(s).push(m);
    }
    [...grupos.keys()].sort((a, b) => a - b).forEach((s) => {
      const sec = el("div", { class: "semestre", "data-sem": s });
      const bm = el("button", { type: "button", text: "Marcar todo" });
      bm.addEventListener("click", () => marcarSemestre(sec, true));
      const bd = el("button", { type: "button", text: "Quitar" });
      bd.addEventListener("click", () => marcarSemestre(sec, false));
      sec.append(el("div", { class: "semestre-titulo" },
        el("span", { text: s ? "Semestre " + s : "Sin semestre" }),
        el("span", null, bm, bd)));
      const items = el("div", { class: "semestre-items" });
      for (const m of grupos.get(s)) {
        const cb = el("input", { type: "checkbox", value: m.id });
        cb.addEventListener("change", actualizarContador);
        const lab = el("label", { class: "item", "data-buscar": normalizar(m.nombre + " " + m.id) },
          cb, el("span", { text: m.nombre }));
        items.append(lab);
      }
      sec.append(items);
      ui.lista.append(sec);
    });
    actualizarContador();
  }

  function marcarSemestre(sec, valor) {
    sec.querySelectorAll(".item:not([hidden]) input").forEach((c) => (c.checked = valor));
    actualizarContador();
  }
  function seleccionadas() {
    return [...ui.lista.querySelectorAll("input[type=checkbox]:checked")].map((c) => c.value);
  }
  function actualizarContador() { ui.contador.textContent = String(seleccionadas().length); }

  function llenarMeta() {
    vaciar(ui.meta);
    ui.meta.append(el("option", { value: "", text: "— Elige una materia —" }));
    for (const m of catalogo) {
      ui.meta.append(el("option", { value: m.id, text: "S" + (m.semestre ?? "?") + " · " + m.nombre }));
    }
  }

  ui.buscador.addEventListener("input", () => {
    const q = normalizar(ui.buscador.value.trim());
    ui.lista.querySelectorAll(".item").forEach((it) => {
      it.hidden = q !== "" && !it.dataset.buscar.includes(q);
    });
    ui.lista.querySelectorAll(".semestre").forEach((s) => {
      s.hidden = !s.querySelector(".item:not([hidden])");
    });
  });
  ui.limpiar.addEventListener("click", () => {
    ui.lista.querySelectorAll("input[type=checkbox]").forEach((c) => (c.checked = false));
    actualizarContador();
  });

  /* ---------- formulario ---------- */
  function actualizarCampos() {
    const t = ui.tipo.value;
    ui.campoMeta.hidden = t !== "ruta";
    ui.campoMax.hidden = t !== "combinaciones";
    ui.ayudaTipo.textContent = AYUDAS[t] || "";
  }
  ui.tipo.addEventListener("change", () => { actualizarCampos(); ocultarEstado(); });
  actualizarCampos();

  function setCargando(on) {
    ui.btn.disabled = on;
    ui.spinner.hidden = !on;
    ui.btnTexto.textContent = on ? "Consultando…" : "Consultar";
  }

  function validarLocal() {
    if (!catalogo.length) return "El catálogo aún no se ha cargado. Espera un momento o pulsa “Reintentar”.";
    const t = ui.tipo.value;
    if (t === "ruta" && !ui.meta.value) {
      return "Datos insuficientes: elige la materia meta para calcular la ruta.";
    }
    if (t === "combinaciones") {
      const v = ui.max.value.trim();
      const n = Number(v);
      if (v === "" || !Number.isInteger(n) || n < 1 || n > 10) {
        return "Valor no válido: el máximo de materias debe ser un entero entre 1 y 10.";
      }
    }
    return null;
  }

  ui.form.addEventListener("submit", async (ev) => {
    ev.preventDefault();
    ocultarEstado();
    const problema = validarLocal();
    if (problema) {
      mostrarEstado("aviso", problema);
      limpiarResultados(false);
      return;
    }
    const cuerpo = { tipo: ui.tipo.value, aprobadas: seleccionadas() };
    if (cuerpo.tipo === "ruta") cuerpo.meta = ui.meta.value;
    if (cuerpo.tipo === "combinaciones") cuerpo.max = Number(ui.max.value);

    setCargando(true);
    try {
      const d = await pedir(API.consultar, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(cuerpo)
      });
      pintarRespuesta(d, cuerpo);
    } catch (e) {
      limpiarResultados(false);
      const reintento = e.red ? el("button", { type: "button", class: "btn btn-sec", text: "Reintentar" }) : null;
      if (reintento) reintento.addEventListener("click", () => ui.form.requestSubmit());
      const tipo = e.status && e.status >= 400 && e.status < 500 ? "aviso" : "error";
      mostrarEstado(tipo, e.message + (reintento ? " " : ""), reintento);
    } finally {
      setCargando(false);
    }
  });

  ui.reiniciar.addEventListener("click", () => {
    if (abortActual) abortActual.abort();
    ui.limpiar.click();
    ui.buscador.value = ""; ui.buscador.dispatchEvent(new Event("input"));
    ui.tipo.value = "disponibles"; ui.meta.value = ""; ui.max.value = "5";
    actualizarCampos(); ocultarEstado(); limpiarResultados(true);
    window.scrollTo({ top: 0, behavior: "smooth" });
  });

  /* ---------- resultados ---------- */
  function limpiarResultados(conAyuda) {
    vaciar(ui.resultados);
    ui.porque.hidden = true; ui.porque.open = false; vaciar(ui.porqueCont);
    if (conAyuda) ui.resultados.append(el("p", { class: "ayuda", text: "Aquí aparecerán los resultados de tu consulta." }));
  }

  function chip(m, falta) {
    return el("span", { class: "chip" + (falta ? " falta" : ""), text: m.nombre || nombreDe(m.id) });
  }

  function pintarRespuesta(d, cuerpo) {
    limpiarResultados(false);
    const res = Array.isArray(d.resultados) ? d.resultados : [];

    if (!res.length || d.total === 0) {
      mostrarEstado("info", d.mensaje || "Sin resultados para esta consulta.");
      return;
    }

    let resumen = d.total + (d.total === 1 ? " resultado" : " resultados");
    if (d.tipo === "ruta") resumen = "Ruta en " + d.total + (d.total === 1 ? " semestre" : " semestres");
    ui.resultados.append(el("p", { class: "resumen", text: resumen }));
    if (d.truncado) {
      mostrarEstado("aviso", "Se muestran solo los primeros resultados (el servidor limita la cantidad).");
    }

    switch (d.tipo) {
      case "disponibles": pintarDisponibles(res); break;
      case "bloqueadas": pintarBloqueadas(res); break;
      case "ruta": pintarRuta(res); break;
      case "combinaciones": pintarCombinaciones(res); break;
      default: ui.resultados.append(el("p", { text: "Tipo de respuesta no reconocido." }));
    }
    pintarExplicacion(d.explicacion);
  }

  function pintarDisponibles(res) {
    const g = el("div", { class: "cuadricula" });
    for (const m of res) {
      g.append(el("div", { class: "mini" },
        el("h3", { text: m.nombre }),
        el("span", { class: "etiqueta", text: m.semestre ? "Semestre " + m.semestre : "Sin semestre" }),
        el("span", { class: "etiqueta", text: "Disponible" })));
    }
    ui.resultados.append(g);
  }

  function pintarBloqueadas(res) {
    const g = el("div", { class: "cuadricula" });
    for (const m of res) {
      const chips = el("div", { class: "chips" });
      (m.faltantes || []).forEach((f) => chips.append(chip(f, true)));
      g.append(el("div", { class: "mini bloq" },
        el("h3", { text: m.nombre }),
        el("span", { class: "etiqueta", text: m.semestre ? "Semestre " + m.semestre : "Sin semestre" }),
        el("div", { class: "subtit", text: "Te falta aprobar (prerrequisitos o materias atrasadas):" }),
        chips));
    }
    ui.resultados.append(g);
  }

  function pintarRuta(res) {
    const ol = el("ol", { class: "ruta" });
    for (const paso of res) {
      const chips = el("div", { class: "chips" });
      (paso.materias || []).forEach((m) => chips.append(chip(m, false)));
      ol.append(el("li", null, el("h3", { text: "Semestre " + paso.semestre + " de la ruta" }), chips));
    }
    ui.resultados.append(ol);
  }

  function pintarCombinaciones(res) {
    res.forEach((c, i) => {
      const chips = el("div", { class: "chips" });
      (c.materias || []).forEach((m) => chips.append(chip(m, false)));
      ui.resultados.append(el("div", { class: "mini combo" },
        el("h3", { text: "Opción " + (i + 1) }),
        el("span", { class: "etiqueta", text: (c.cantidad ?? (c.materias || []).length) + " materia(s)" }),
        chips));
    });
  }

  function pintarExplicacion(exps) {
    vaciar(ui.porqueCont);
    if (!Array.isArray(exps) || !exps.length) { ui.porque.hidden = true; return; }
    for (const e of exps) {
      const ul = el("ul");
      (e.razon || []).forEach((r) => ul.append(el("li", { text: r })));
      ui.porqueCont.append(el("div", { class: "por-materia" },
        el("h4", { text: e.materia ? e.materia.nombre : "" }), ul));
    }
    ui.porque.hidden = false;
  }

  /* ---------- inicio ---------- */
  cargarCatalogo();
})();
