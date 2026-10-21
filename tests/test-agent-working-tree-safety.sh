#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agents_file="$REPO_DIR/AGENTS.md"

for rule in \
  'Antes de editar, registra `git status --short`' \
  'El origen no se deduce de `git status`.' \
  'Sin evidencia, no llames los cambios "ajenos" ni "del usuario".' \
  'Trata los cambios previos y los ficheros sin seguimiento fuera del alcance' \
  'No los sobrescribas, formatees, renombres, elimines,' \
  'guardes en stash, añadas al índice ni incluyas en commits/push salvo que la tarea' \
  'los nombre y el usuario autorice esa acción.' \
  'Añade sólo las rutas autorizadas por la tarea' \
  'nunca `git add -A`' \
  'Si una' \
  'operación de rama, merge o actualización puede afectar esas rutas, para y' \
  'pregunta antes de continuar.' \
  'Un push publica commits; no incluye cambios sin commit ni ficheros sin' \
  'Si el usuario pide «subir todos los cambios» y hay rutas locales sin commit,' \
  'pregunta qué rutas quiere incluir antes de prepararlas'; do
  if ! grep -Fq -- "$rule" "$agents_file"; then
    printf 'FAIL: AGENTS.md is missing working-tree safety rule: %s\n' "$rule" >&2
    exit 1
  fi
done

printf 'PASS: AGENTS.md protects uncommitted work and avoids guessing its owner\n'
