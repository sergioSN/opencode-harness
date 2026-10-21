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

printf 'PASS: AGENTS.md requires English atomic commits and change-type branch prefixes\n'
