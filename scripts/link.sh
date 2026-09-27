#!/usr/bin/env bash
# ============================================================
# link.sh — enlaza este repo con ~/.config/opencode/
# ------------------------------------------------------------
# El repo ES la configuración global de opencode. En vez de
# copiar ficheros, se enlazan: los cambios se ven al instante y
# no hay dos copias que se desincronicen.
#
# Se enlazan cinco cosas (rutas confirmadas con
# `opencode debug paths` y la doc de V2):
#   opencode.jsonc  ->  ~/.config/opencode/opencode.jsonc   (config)
#   AGENTS.md       ->  ~/.config/opencode/AGENTS.md        (instrucciones)
#   agents/         ->  ~/.config/opencode/agents/          (agents)
#   skills/         ->  ~/.config/opencode/skills/          (skills)
#   commands/       ->  ~/.config/opencode/commands/        (comandos /slash)
#
# Ojo: los comandos van en `commands/` (plural). El singular `command/` es
# legado y aún se lee, pero no se usa para ficheros nuevos.
#
# Uso:
#   link.sh                # crea o refresca los enlaces
#   link.sh --check        # solo informa, no toca nada
#   link.sh --unlink       # quita SOLO los enlaces a este repo
#   FORCE=1 link.sh        # pisa lo que haya, guardando copia antes
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OC_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
LINKED=(opencode.jsonc AGENTS.md agents skills commands)

FORCE="${FORCE:-0}"
MODE="link"

for arg in "$@"; do
  case "$arg" in
    --check)   MODE="check" ;;
    --unlink)  MODE="unlink" ;;
    -h|--help) sed -n '2,22p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "link.sh: opción desconocida: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '   %s\n' "$*"; }
warn() { printf '   ! %s\n' "$*" >&2; }
ok()   { printf '   \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '   \033[31m✗\033[0m %s\n' "$*"; }

# Destino real de un symlink, o el propio path si no lo es.
destino() {
  if [ -L "$1" ]; then readlink -f "$1"; else printf '%s' "$1"; fi
}

es_este_repo() {
  case "$(destino "$1")" in "$REPO_DIR"/*) return 0 ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------- check
if [ "$MODE" = "check" ]; then
  echo "Estado de los enlaces ($OC_DIR)"
  echo
  fallos=0
  for n in "${LINKED[@]}"; do
    src="$REPO_DIR/$n"; dst="$OC_DIR/$n"
    if [ ! -e "$src" ]; then
      bad "$n  (no existe en el repo: $src)"; fallos=$((fallos+1)); continue
    fi
    if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
      bad "$n  sin enlazar"; fallos=$((fallos+1))
    elif [ -L "$dst" ] && es_este_repo "$dst"; then
      ok "$n  -> $(destino "$dst")"
    else
      bad "$n  YA NO ES ENLACE (lo sustituyó otro programa). Real: $(destino "$dst")"
      say "Recuperación: guarda lo que quieras conservar y ejecuta: FORCE=1 link.sh"
      fallos=$((fallos+1))
    fi
  done
  echo
  [ "$fallos" -eq 0 ] && ok "todo correcto" || bad "$fallos problema(s)"
  exit "$fallos"
fi

# --------------------------------------------------------------- unlink
if [ "$MODE" = "unlink" ]; then
  echo "Quitando enlaces de $OC_DIR"
  echo
  for n in "${LINKED[@]}"; do
    dst="$OC_DIR/$n"
    if [ -L "$dst" ] && es_este_repo "$dst"; then
      rm -f "$dst"; ok "quitado $n"
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
      warn "$n no es un enlace a este repo: no se toca"
    else
      say "$n no estaba enlazado"
    fi
  done
  echo
  say "Lo que hubiera en esos sitios sigue intacto donde lo tuvieras."
  exit 0
fi

# ----------------------------------------------------------------- link
echo "Enlazando $REPO_DIR  ->  $OC_DIR"
echo
mkdir -p "$OC_DIR"

for n in "${LINKED[@]}"; do
  src="$REPO_DIR/$n"; dst="$OC_DIR/$n"

  if [ ! -e "$src" ]; then
    bad "$n no existe en el repo"; continue
  fi

  if [ -L "$dst" ] && es_este_repo "$dst"; then
    ok "$n  ya enlazado"; continue
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      if [ -L "$dst" ]; then
        bad "$n apunta a $(destino "$dst"), no a este repo"
      else
        bad "$n existe y NO es un enlace. No se toca (usa FORCE=1)"
      fi
      say "  Se guardaría una copia: $dst.backup-AAAmmddHHMMSS"
      continue
    fi
    bak="$dst.backup-$(date +%Y%m%d%H%M%S)"
    cp -a "$dst" "$bak" 2>/dev/null || true
    rm -rf "$dst"
    ok "$n  copiado a $(basename "$bak") y sustituido"
  fi

  ln -s "$src" "$dst"
  ok "$n  -> $src"
done

echo
say "Abre opencode en una terminal nueva, o ejecuta: opencode reload"
