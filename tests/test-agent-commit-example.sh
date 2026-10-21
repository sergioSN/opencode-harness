#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agents_file="$REPO_DIR/AGENTS.md"

if grep -qi 'superpowers' "$agents_file"; then
  printf 'FAIL: AGENTS.md still uses a vendor-specific dependency example\n' >&2
  exit 1
fi
if ! grep -Fq 'feat(auth): refresh the token before it expires' "$agents_file"; then
  printf 'FAIL: AGENTS.md does not show an English Conventional Commit subject\n' >&2
  exit 1
fi
if ! grep -Fq 'el asunto como el cuerpo se escriben en inglés' "$agents_file"; then
  printf 'FAIL: AGENTS.md does not require commit messages in English\n' >&2
  exit 1
fi
if ! grep -Fq 'Un commit, un cambio lógico' "$agents_file"; then
  printf 'FAIL: AGENTS.md does not require atomic commits\n' >&2
  exit 1
fi
for branch_rule in \
  '- `feature/`: funcionalidad o capacidad nueva.' \
  '- `fix/`: corrige bugs; `bugfix/` es alias aceptado, pero se prefiere `fix/` para nuevas ramas.' \
  '- `hotfix/`: corrección urgente y muy acotada; no es sinónimo de un fix pequeño.' \
  '- Para otros trabajos, usa el tipo correspondiente: `docs/`, `style/`, `refactor/`,' \
  '`perf/`, `test/`, `build/`, `chore/` o `revert/`.' \
  'feature/openchamber-child-learning-ux' \
  'fix/openchamber-drawing-controls' \
  'hotfix/session-auth-expired' \
  'openchamber/child-learning-ux`. Una corrección'; do
  if ! grep -Fq -- "$branch_rule" "$agents_file"; then
    printf 'FAIL: AGENTS.md does not define branch naming policy: %s\n' "$branch_rule" >&2
    exit 1
  fi
done

for base_rule in \
  'Antes de crear una rama o redactar/actualizar una spec o un plan' \
  'git fetch --all' \
  'remoto de integración del proyecto' \
  'Revisa `git status` y conserva todo el trabajo local.' \
  'Trabajo normal: elige la rama upstream más reciente, priorizando `develop`, luego `main` y `master`.' \
  'incorpora los cambios recientes de esa base antes de redactar/actualizar una' \
  'spec o un plan, siguiendo la política del proyecto.' \
  'Si sólo existe `develop` local sin upstream, pregunta;' \
  'no supongas que está al día.' \
  'No uses reset, checkout' \
  'forzado ni descartes cambios locales.' \
  'Si el árbol sucio o una divergencia impiden actualizar sin riesgo' \
  'pide una decisión; no continúes con una base obsoleta.' \
  '**Hotfix:** `hotfix/*` sale siempre de la última `main` upstream' \
  'desde `master`, aunque exista `develop`' \
  'aunque exista `develop`' \
  'Si esa base no puede identificarse o' \
  'actualizarse con seguridad, pregunta antes' \
  'de crear la rama o redactar el plan.'; do
  if ! grep -Fq -- "$base_rule" "$agents_file"; then
    printf 'FAIL: AGENTS.md does not define branch/spec freshness rule: %s\n' "$base_rule" >&2
    exit 1
  fi
done

line_number() {
  grep -nF -- "$1" "$agents_file" | head -1 | cut -d: -f1
}

prepare_line="$(line_number 'Antes de crear una rama o redactar/actualizar una spec o un plan')"
fetch_line="$(line_number 'Ejecuta `git fetch --all`')"
base_line="$(line_number 'Trabajo normal: elige la rama upstream más reciente')"
create_line="$(line_number 'Crea la rama nueva directamente desde esa base')"
sync_line="$(line_number 'incorpora los cambios recientes de esa base')"
plan_line="$(line_number 'spec o un plan, siguiendo la política del proyecto.')"
if [ -z "$prepare_line" ] || [ -z "$fetch_line" ] || [ -z "$base_line" ] \
    || [ -z "$create_line" ] || [ -z "$sync_line" ] || [ -z "$plan_line" ] \
    || [ "$fetch_line" -le "$prepare_line" ] || [ "$base_line" -le "$fetch_line" ] \
    || [ "$create_line" -le "$base_line" ] || [ "$sync_line" -lt "$create_line" ] \
    || [ "$plan_line" -lt "$sync_line" ]; then
  printf 'FAIL: AGENTS.md does not require fetching and synchronizing before branching or planning\n' >&2
  exit 1
fi

printf 'PASS: AGENTS.md requires English atomic commits and change-type branch prefixes\n'
