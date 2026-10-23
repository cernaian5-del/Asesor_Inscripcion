#!/usr/bin/env bash
# Pruebas de humo con curl contra la API.
#   Local:    ./tests/probar_api.sh http://localhost:8080
#   Pública:  ./tests/probar_api.sh https://TU-APP.onrender.com
# Los IDs de materia se leen de /api/materias, así que funciona con tu catálogo.
# Requiere: bash, curl. (No requiere jq.)

BASE="${1:-http://localhost:8080}"
BASE="${BASE%/}"
PASS=0; FAIL=0
H='Content-Type: application/json'

# post <descripción> <código_esperado> <json>
post() {
  local desc="$1" esperado="$2" cuerpo="$3" salida codigo
  salida=$(curl -s -m 30 -w '\n%{http_code}' -H "$H" -d "$cuerpo" "$BASE/api/consultar")
  codigo="${salida##*$'\n'}"; salida="${salida%$'\n'*}"
  mostrar "$desc" "$esperado" "$codigo" "$salida"
}
# get <descripción> <código_esperado> <ruta>
get() {
  local desc="$1" esperado="$2" ruta="$3" salida codigo
  salida=$(curl -s -m 30 -w '\n%{http_code}' "$BASE$ruta")
  codigo="${salida##*$'\n'}"; salida="${salida%$'\n'*}"
  mostrar "$desc" "$esperado" "$codigo" "$salida"
}
mostrar() {
  local desc="$1" esperado="$2" codigo="$3" salida="$4"
  if [ "$codigo" = "$esperado" ]; then PASS=$((PASS+1)); marca="OK  "; else FAIL=$((FAIL+1)); marca="FALLA"; fi
  echo "[$marca] $desc  (HTTP $codigo, esperado $esperado)"
  echo "$salida" | tr -d '\n' | tr -s ' ' | cut -c1-300; echo; echo
}

echo "== Probando $BASE =="
get "Healthcheck" 200 "/health"
get "Página principal (estático)" 200 "/"
get "Ruta de API inexistente" 404 "/api/nada"

# IDs reales del catálogo
IDS=$(curl -s -m 30 "$BASE/api/materias" | grep -o '"id":"[^"]*"' | sed 's/"id":"//; s/"$//')
if [ -z "$IDS" ]; then
  echo "No se pudo leer el catálogo desde /api/materias. ¿Está llena conocimiento.pl?"; exit 1
fi
M1=$(echo "$IDS" | sed -n '1p'); M2=$(echo "$IDS" | sed -n '2p'); MN=$(echo "$IDS" | tail -n 1)
echo "IDs usados: primera=$M1 segunda=$M2 última(meta)=$MN"; echo

get  "Catálogo de materias" 200 "/api/materias"
post "Disponibles (sin aprobadas)"            200 '{"tipo":"disponibles","aprobadas":[]}'
post "Disponibles (con aprobadas)"            200 "{\"tipo\":\"disponibles\",\"aprobadas\":[\"$M1\",\"$M2\"]}"
post "Bloqueadas"                              200 '{"tipo":"bloqueadas","aprobadas":[]}'
post "Ruta hacia la última materia"           200 "{\"tipo\":\"ruta\",\"aprobadas\":[],\"meta\":\"$MN\"}"
post "Combinaciones (max 3)"                  200 "{\"tipo\":\"combinaciones\",\"aprobadas\":[\"$M1\"],\"max\":3}"
post "Datos incompletos: ruta sin meta"        400 '{"tipo":"ruta","aprobadas":[]}'
post "Datos incompletos: sin 'aprobadas'"      400 '{"tipo":"disponibles"}'
post "Tipo no permitido"                       400 '{"tipo":"borrar","aprobadas":[]}'
post "max fuera de rango (0)"                  400 '{"tipo":"combinaciones","aprobadas":[],"max":0}'
post "max fuera de rango (11)"                 400 '{"tipo":"combinaciones","aprobadas":[],"max":11}'
post "max no entero"                           400 '{"tipo":"combinaciones","aprobadas":[],"max":"abc"}'
post "ID de materia inexistente"               400 '{"tipo":"disponibles","aprobadas":["no_existe"]}'
post "Intento de inyección Prolog"             400 '{"tipo":"disponibles","aprobadas":["calculo), halt, foo("]}'
post "Aprobadas repetidas"                     400 "{\"tipo\":\"disponibles\",\"aprobadas\":[\"$M1\",\"$M1\"]}"
post "JSON malformado"                         400 '{"tipo": '
get  "Método incorrecto (GET en /consultar)"   405 "/api/consultar"

echo "== Resumen: $PASS correctas, $FAIL con fallas =="
[ "$FAIL" -eq 0 ]
