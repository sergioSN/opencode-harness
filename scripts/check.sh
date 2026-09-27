#!/usr/bin/env bash
# ============================================================
# check.sh — diagnóstico del estado real
# ------------------------------------------------------------
# Notrusta en parsear el JSON a mano: pregunta al propio
# opencode, que es quien lee la config de verdad. Si
# `opencode debug config` no escupe un JSON, el config está
# mal formado y todo lo demás da igual.
# ============================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OC_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
SP_SKILLS="$HOME/.local/share/superpowers/node_modules/superpowers/skills"

# El PATH no interactivo de WSL no trae ~/.local/bin, y fue
# exactamente lo que escondió el launcher de openchamber.
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

h()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
say(){ printf '   %s\n' "$*"; }
ok() { printf '   \033[32m✓\033[0m %s\n' "$*"; }
bad(){ printf '   \033[31m✗\033[0m %s\n' "$*"; }
warn_(){ printf '   \033[33m!\033[0m %s\n' "$*"; }
fallos=0
fallar(){ fallos=$((fallos+1)); }

# ------------------------------------------------------------- 1. enlaces
h "1. Enlaces con $OC_DIR"
bash "$REPO_DIR/scripts/link.sh" --check || fallar

# -------------------------------------------------------------- 2. config
h "2. Config (la parsea opencode, no nosotros)"
if ! config_json="$(opencode debug config 2>&1)"; then
  bad "opencode no pudo leer la configuración:"
  say "$config_json" | head -20
  fallar
elif echo "$config_json" | grep -q '"type": *"document"'; then
  ok "opencode.jsonc válido y legible"
  # ¿está el symlink vivo, o lo sustituyó alguien?
  if [ -L "$OC_DIR/opencode.jsonc" ] && \
     [ "$(readlink -f "$OC_DIR/opencode.jsonc")" = "$REPO_DIR/opencode.jsonc" ]; then
    ok "sigue siendo un symlink a este repo"
  else
    bad "opencode.jsonc ya NO es el symlink de este repo"
    say "  Suele pasar cuando una herramienta reescribe la config in situ."
    say "  Solución: FORCE=1 make link   (guarda copia de la anterior)"
    fallar
  fi
  echo
  say "orígenes que opencode está leyendo:"
  echo "$config_json" | grep -oE '"path": "[^"]+"' | sed 's/^/     /'
else
  bad "opencode debug config no devolvió config utilizable"
  say "$config_json" | head -20
  fallar
fi

# `opencode mcp list`, `opencode plugin list` y `opencode debug agents` no leen
# el disco: preguntan al service en background, que puede seguir con la config
# de antes. Sin recargar, dan falsos negativos ("No MCP servers configured") y
# hacen pensar que la config está mal cuando lo que está es el service desfasado.
#
# Y `opencode reload` solo recarga un service VIVO, que no es lo mismo que
# tenerlo al día: si el service está muerto, o si arrancó antes de que existiera
# lo que estamos mirando, sigue sirviendo su snapshot viejo. La firma es que el
# catálogo de agents viene con los 4+3 de fábrica y sin los globales, y el
# `mcp list` dice que no hay servidores. En ese caso hay que matarlo para que la
# CLI lo levante otra vez ya con la config buena.
echo
say "asegurándome de que el service tiene la config actual..."
opencode reload >/dev/null 2>&1 || warn_ "\`opencode reload\` falló"
# El service se levanta por demanda y tarda un par de segundos en cargar la
# config global. Sin esta espera, la primera consulta le llega mientras
# todavía arranca, devuelve el catalogo vacio, y el script se diagnosticaria
# a sí mismo como "service desfasado" cuando lo único que pasa es que tiene
# prisa.
sleep 3

ve_globales() {
  opencode debug agents 2>/dev/null | grep -c '"id": "developer"'
}

# Mata el service y espera a que la CLI lo levante ya con la config buena.
# No basta con dormir una vez y reintentar: el arranque tarda, y durante esa
# ventana cada `opencode debug` responde a medias.
reiniciar_service() {
  pkill -f 'opencode serve --service' >/dev/null 2>&1 || true
  sleep 2
  for _ in 1 2 3 4 5 6 7 8; do
    opencode reload >/dev/null 2>&1 || true
    sleep 2
    [ "$(ve_globales)" -ge 1 ] && return 0
  done
  return 1
}

if [ "$(ve_globales)" -ge 1 ]; then
  ok "el service ve los agents globales"
else
  say "el service no ve los agents globales: reiniciándolo"
  if reiniciar_service; then
    ok "service reiniciado y ya ve los agents globales"
  else
    warn_ "tras reiniciarlo tampoco aparecen. Si acabas de crear el fichero,"
    say "  mira que el symlink siga vivo (sección 1) y abre una terminal nueva."
  fi
fi

# ------------------------------------------------------------- 3. plugins
h "3. Plugins"
if echo "$config_json" 2>/dev/null | grep -q 'superpowers@git+'; then
  ok "superpowers declarado en \`plugins\`"
else
  bad "superpowers no está en \`plugins\`"
  fallar
fi
plugin_list="$(opencode plugin list 2>&1)"
say "opencode plugin list dice:"
printf '%s\n' "$plugin_list" | sed -n '1,8p' | sed 's/^/     /'
say ""
if echo "$plugin_list" | grep -q 'superpowers'; then
  ok "superpowers registrado en el service"
else
  warn_ "superpowers no aparece en \`opencode plugin list\`"
fi
warn_ "Estar registrado no significa que funcione: su plugin usa hooks de V1"
say "(config.skills.paths y experimental.chat.messages.transform), y el doc de"
say "migración dice que los plugins de V1 no corren en V2. Lo que sí funciona"
say "son los 15 skills, y llegan por el array \`skills\` de la config. Sección 4."

# -------------------------------------------------------------- 4. skills
h "4. Skills de superpowers (vía array \`skills\` de V2)"
if [ -d "$SP_SKILLS" ]; then
  n=$(find "$SP_SKILLS" -name SKILL.md 2>/dev/null | wc -l)
  if [ "$n" -gt 0 ]; then
    ok "$n skills instalados en $(basename "$(dirname "$SP_SKILLS")")/superpowers/skills"
    find "$SP_SKILLS" -name SKILL.md 2>/dev/null | sed "s|$SP_SKILLS/||;s|/SKILL.md||" \
      | sort | tr '\n' ' ' | fold -s -w 66 | sed 's/^/     /'
  else
    bad "el directorio existe pero no hay ningún SKILL.md"
    fallar
  fi
else
  bad "no está instalado: $SP_SKILLS"
  say "  Solución: make superpowers"
  fallar
fi

# ----------------------------------------------------------------- 5. mcp
h "5. MCP (mcp.servers)"
if echo "$config_json" 2>/dev/null | grep -q '"servers"'; then
  ok "bloque \`mcp.servers\` presente (forma V2)"
else
  bad "no hay bloque \`mcp.servers\`"
  fallar
fi
for srv in context7 codegraph; do
  if echo "$config_json" 2>/dev/null | grep -q "\"$srv\""; then
    ok "$srv declarado"
  else
    bad "$srv no está declarado"
    fallar
  fi
done
echo
say "opencode mcp list dice:"

# Tras el reload los MCP aparecen como "pending" mientras conectan. Es
# transitorio, así que se espera un poco en vez de reportarlo.
mcp_out=""
for _ in 1 2 3 4; do
  mcp_out="$(opencode mcp list 2>&1)"
  echo "$mcp_out" | grep -q 'pending' || break
  sleep 2
done
echo "$mcp_out" | sed -n '1,15p' | sed 's/^/     /'

# Declarado no es lo mismo que conectado. Un MCP en failed es un problema real
# (binario que falta, PORT mal, server que no arranca) y no debe pasar por
# bueno solo por estar escrito en la config.
if echo "$mcp_out" | grep -q 'failed'; then
  bad "algún MCP no conecta"
  echo "$mcp_out" | grep 'failed' | sed 's/^/     /'
  fallar
else
  ok "ningún MCP en failed"
fi

# ------------------------------------------------------------ 6. binarios
h "6. Binarios"
if command -v codegraph >/dev/null 2>&1; then
  ok "codegraph -> $(command -v codegraph)"
else
  warn_ "codegraph no está en el PATH"
  say "  El MCP de codegraph es local, así que opencode tiene que poder"
  say "  encontrarlo. Solución: make codegraph"
  say "  Si lo instalas y sigue sin verse, casi seguro es que opencode arranque"
  say "  con otro PATH: pon la ruta absoluta en mcp.servers.codegraph.command."
  fallar
fi
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ok "~/.local/bin está en el PATH de este script" ;;
  *) warn_ "~/.local/bin no está en el PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.opencode/bin:"*) ok "~/.opencode/bin está en el PATH de este script" ;;
  *) warn_ "~/.opencode/bin no está en el PATH" ;;
esac

# -------------------------------------------------------------- 7. agentes
h "7. Agents globales"
agents_json="$(opencode debug agents 2>/dev/null)"
n_agents=$(printf '%s' "$agents_json" | grep -c '"id":' || true)
if [ "$n_agents" -gt 0 ]; then
  ok "$n_agents agents en total (4 de opencode + 3 de mantenimiento ocultos + los globals)"
  printf '%s' "$agents_json" | grep -oE '"id": "[^"]+"' \
    | sed 's/"id": "//; s/"$//' | sort \
    | tr '\n' ' ' | fold -s -w 66 | sed 's/^/     /'
else
  bad "opencode debug agents no devolvió nada"
  fallar
fi
echo

# No basta con que el fichero exista: tiene que aparecer en el catálogo que es
# lo que el modelo lee para lanzar subagents.
for a in developer reviewer; do
  if printf '%s' "$agents_json" | grep -q "\"id\": \"$a\""; then
    ok "$a registrado en el catálogo"
  else
    bad "$a NO aparece en \`opencode debug agents\`"
    say "  Si lo acabas de crear: opencode reload, y abre una terminal nueva."
    fallar
  fi
done

# El reviewer vale por ser de solo lectura. Dos cosas se comprican:
#   1. que `edit` esté denegado, y
#   2. que el deny general de shell vaya ANTES que la excepción `git *`.
# Gana la última regla que coincide, así que con el orden invertido el deny se
# come el allow y el reviewer se queda sin poder ni hacer `git diff`. Es un
# fallo silencioso: el agente existe, responde, y no puede ver el cambio.
#
# `opencode debug agents` devuelve JSON con sangrado, así que se pasan los
# saltos de línea a espacios y se buscan patrones tolerantes al sangrado.
# OJO: no usar `tr -d ' '` — borraría el espacio de `"git *"` y el patrón
# jamais casaría, dando un falso "sin excepción git".
if printf '%s' "$agents_json" | grep -q '"id": "reviewer"'; then
  flat="$(printf '%s' "$agents_json" | tr '\n' ' ')"

  if printf '%s' "$flat" | grep -qE '"action": *"edit", *"resource": *"\*", *"effect": *"deny"'; then
    ok "reviewer: \`edit\` denegado (no puede escribir ficheros)"
  else
    bad "reviewer NO tiene \`edit\` denegado: podría modificar el código que revisa"
    fallar
  fi

  dpos=$(printf '%s' "$flat" | grep -boE '"action": *"shell", *"resource": *"\*", *"effect": *"deny"' \
         | head -1 | cut -d: -f1)
  apos=$(printf '%s' "$flat" | grep -boE '"action": *"shell", *"resource": *"git \*", *"effect": *"allow"' \
         | head -1 | cut -d: -f1)

  if [ -z "$apos" ]; then
    bad "reviewer: sin excepción \`git *\`. No podrá producir el diff de la tarea."
    say "  Añade en agents/reviewer.md, DESPUÉS del deny general de shell:"
    say "    - action: shell / resource: \"git *\" / effect: allow"
    fallar
  elif [ -z "$dpos" ]; then
    warn_ "reviewer: no hay deny general de shell (revisar que no se pueda ejecutar nada más)"
  elif [ "$dpos" -lt "$apos" ]; then
    ok "reviewer: shell denegado salvo \`git *\` (orden correcto)"
  else
    bad "reviewer: el deny de shell va DESPUÉS de la excepción \`git *\`"
    say "  Gana la última regla que coincide, así que el deny se come el allow"
    say "  y el reviewer no puede ni ejecutar \`git diff\`. El deny va antes."
    fallar
  fi
fi

if [ -e "$OC_DIR/AGENTS.md" ]; then
  ok "AGENTS.md presente (instrucciones globales)"
else
  bad "no hay AGENTS.md en $OC_DIR"
  fallar
fi

# ------------------------------------------------------------- 8. commands
# `find` sin -L no baja por un symlink a directorio: daría 0 ficheros aunque
# `commands/ship.md` exista, que es justo el fallo que hay que cazar aquí.
h "8. Comandos globales"
if [ -e "$OC_DIR/commands" ]; then
  n_cmd=$(find -L "$OC_DIR/commands" -name '*.md' 2>/dev/null | wc -l)
  if [ "$n_cmd" -gt 0 ]; then
    ok "$n_cmd comando(s) global(es)"
    find -L "$OC_DIR/commands" -name '*.md' 2>/dev/null \
      | sed "s|$OC_DIR/commands/||; s|\.md$||" | sort \
      | sed 's/^/     \//'
    echo
    # Sin `description` en el frontmatter, el comando aparece en blanco en la
    # lista del TUI y nadie sabe cuándo usarlo.
    while IFS= read -r f; do
      if head -20 "$f" | grep -q '^description:'; then
        ok "$(basename "$f" .md) tiene description"
      else
        bad "$(basename "$f" .md) sin \`description\`: sale en blanco en el TUI"
        fallar
      fi
    done < <(find -L "$OC_DIR/commands" -name '*.md' 2>/dev/null)
  else
    bad "$OC_DIR/commands está vacío"
    say "  Los comandos llegarían por \`commands/\`. Solución: make link"
    fallar
  fi
else
  bad "no existe $OC_DIR/commands"
  say "  Sin él, /ship no existe. Solución: make link"
  fallar
fi

# ------------------------------------------------------------ 9. skills
h "9. Skills propias"
if [ -d "$REPO_DIR/skills" ]; then
  n_own=$(find "$REPO_DIR/skills" -mindepth 2 -name SKILL.md 2>/dev/null | wc -l)
  if [ "$n_own" -gt 0 ]; then
    ok "$n_own skill(s) propia(s) en el repo"
    find "$REPO_DIR/skills" -mindepth 2 -name SKILL.md 2>/dev/null \
      | sed "s|$REPO_DIR/skills/||; s|/SKILL.md||" | sort \
      | tr '\n' ' ' | fold -s -w 66 | sed 's/^/     /'
    echo
    while IFS= read -r f; do
      if head -20 "$f" | grep -q '^description:'; then
        ok "$(basename "$(dirname "$f")") tiene description (es lo que lee el modelo)"
      else
        bad "$(basename "$(dirname "$f")") sin \`description\`: el modelo no sabrá cuándo cargarla"
        fallar
      fi
    done < <(find "$REPO_DIR/skills" -mindepth 2 -name SKILL.md 2>/dev/null)
  else
    say "ninguna todavía"
  fi
fi

# --------------------------------------------------------------- resumen
h "Resumen"
if [ "$fallos" -eq 0 ]; then
  ok "Todo correcto."
  exit 0
else
  bad "$fallos problema(s). Ver arriba."
  exit "$fallos"
fi
