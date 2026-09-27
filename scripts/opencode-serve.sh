#!/usr/bin/env bash
# ============================================================
#  opencode-serve.sh — servidor web de opencode (start/stop/status)
# ------------------------------------------------------------
#  Por qué un script y no una receta de Make: `opencode serve`
#  arranca en primer plano e imprime una contraseña por stdout.
#  Sin capturarla, el target levanta un servidor cuya web no
#  muestra nada útil: la API responde 401 {"_tag":
#  "UnauthorizedError"} a /api/* y el único sitio donde aparece
#  la clave es el terminal que lo arrancó.
#
#  A diferencia de `openchamber serve`, aquí NO hay /health:
#  /health devuelve el HTML de la SPA, y un 200 ahí no prueba
#  nada. La comprobación real es que el log imprima la contraseña.
# ============================================================
set -uo pipefail

STATE=/tmp/opencode-serve
PORT_DEFAULT=4096

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

say()  { printf '  %s\n' "$*"; }
aviso() { printf '  ⚠ %s\n' "$*"; }
error() { printf '  ❌ %s\n' "$*" >&2; }

usage() {
  cat >&2 <<'EOF'
uso: opencode-serve.sh start <proyecto> [puerto]
     opencode-serve.sh stop  [puerto]
     opencode-serve.sh status [puerto]
EOF
  exit 2
}

# Nombre del fichero de estado, por puerto. El puerto va en el nombre
# porque pueden convivir varios (tests, proyectos distintos).
estado_de() { printf '%s/%s.pid' "$STATE" "$1"; }
log_de()    { printf '%s/%s.log' "$STATE" "$1"; }

vivo() {
  local pf; pf=$(estado_de "$1")
  [ -f "$pf" ] || return 1
  local pid; pid=$(cat "$pf" 2>/dev/null)
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

cmd_start() {
  local proyecto="${1:-}" port="${2:-$PORT_DEFAULT}"
  [ -n "$proyecto" ] || usage
  [ -d "$proyecto" ] || { error "el proyecto no existe: $proyecto"; exit 1; }

  mkdir -p "$STATE"
  local log; log=$(log_de "$port")

  if vivo "$port"; then
    say "ya hay un servidor en el $port (pid $(cat "$(estado_de "$port")"))."
    say "usa  make stop  o cambia de puerto con  OPENCODE_PORT=."
    return 0
  fi

  # El puerto ya ocupado por algo que no es nuestro: no se intenta robar.
  if ss -ltn 2>/dev/null | grep -qE "[:.]$port[[:space:]]"; then
    error "el puerto $port ya está ocupado por otro proceso."
    error "prueba con  OPENCODE_PORT=4097 make opencode-web PROJECT=$proyecto"
    return 1
  fi

  # Se lanza con el proyecto como directorio actual: `opencode serve` no
  # acepta directorio como argumento (su USAGE es `serve [flags]`), así
  # que el cwd es lo único que decide sobre qué proyecto sirve.
  ( cd "$proyecto" && exec opencode serve --hostname 127.0.0.1 --port "$port" ) \
    >"$log" 2>&1 &
  local pid=$!
  echo "$pid" >"$(estado_de "$port")"

  # El server imprime la contraseña al arrancar. Se espera a que aparezca
  # en el log en vez de dormir a ciegas: si tarda más, el aviso es real.
  local pass="" i
  for i in $(seq 1 25); do
    sleep 1
    pass=$(grep -oP 'server password \K\S+' "$log" 2>/dev/null)
    [ -n "$pass" ] && break
    vivo "$port" || break
  done

  echo ""
  say "⚡ opencode serve sobre $proyecto"
  echo ""

  if [ -n "$pass" ]; then
    say "   URL:         http://localhost:$port"
    say "   contraseña:  $pass"
    say ""
    say "   La web la pide al abrir. Es de un solo uso por sesión y el"
    say "   servidor la imprime porque cualquier proceso de tu usuario"
    say "   podría hablar con él; no la guardes en ningún sitio."
  elif vivo "$port"; then
    aviso "el servidor está vivo pero el log no tiene contraseña aún."
    aviso "mira el log:  tail -n 20 $log"
  else
    error "el servidor no arrancó. Log:"
    tail -n 15 "$log" | sed 's/^/      /'
    rm -f "$(estado_de "$port")"
    return 1
  fi
  echo ""
  say "   log:   tail -f $log"
  say "   parar: make stop  (o  bash $0 stop $port)"
}

cmd_stop() {
  local port="${1:-$PORT_DEFAULT}"
  local pf; pf=$(estado_de "$port")

  if ! vivo "$port"; then
    say "nada escuchando en el $port que sea nuestro."
    rm -f "$pf"
    return 0
  fi

  local pid; pid=$(cat "$pf")
  kill "$pid" 2>/dev/null
  # Se espera a que muera de verdad antes de borrar el estado, o un
  # start inmediato siguiente creería que el puerto sigue ocupado.
  local i
  for i in $(seq 1 10); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.3
  done
  kill -9 "$pid" 2>/dev/null
  rm -f "$pf"
  say "servidor del $port detenido (pid $pid)."
}

cmd_status() {
  local port="${1:-$PORT_DEFAULT}"
  local log; log=$(log_de "$port")

  if vivo "$port"; then
    say "opencode serve  EN MARCA  puerto $port  pid $(cat "$(estado_de "$port")")"
    local pass; pass=$(grep -oP 'server password \K\S+' "$log" 2>/dev/null)
    [ -n "$pass" ] && say "                contraseña en $log"
  else
    say "opencode serve  parado    puerto $port"
  fi
}

case "${1:-}" in
  start)  shift; cmd_start  "$@" ;;
  stop)   shift; cmd_stop   "$@" ;;
  status) shift; cmd_status "$@" ;;
  *)      usage ;;
esac
