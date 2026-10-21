#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${SDD_TEST_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FILES=(
  "$REPO_DIR/skills/ship-change/SKILL.md"
  "$REPO_DIR/skills/ship-change/references/spec-plan.md"
  "$REPO_DIR/skills/ship-change/references/brief.md"
  "$REPO_DIR/skills/ship-change/references/ledger.md"
  "$REPO_DIR/agents/developer.md"
  "$REPO_DIR/commands/ship.md"
)
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

for file in "${FILES[@]}"; do
  for legacy in \
    'docs/superpowers/' \
    '.superpowers/sdd/' \
    'test-driven-development' \
    'verification-before-completion' \
    'requesting-code-review' \
    'writing-plans' \
    'subagent-driven-development' \
    'brainstorming'; do
    grep -Fq "$legacy" "$file" && fail "$file still references $legacy"
  done
done

for expected in \
  'docs/specs/YYYY-MM-DD-' \
  'docs/plans/YYYY-MM-DD-' \
  '.work/sdd/YYYY-MM-DD-'; do
  grep -Fq "$expected" "${FILES[@]}" || fail "missing SDD artifact path: $expected"
done

for skill_id in tdd diagnosing-bugs verification code-review codebase-design; do
  grep -Fq "$skill_id" "$REPO_DIR/skills/ship-change/SKILL.md" \
    || fail "ship-change does not reference local skill $skill_id"
done

for rule in \
  'Todo hallazgo diferido tiene destino' \
  'Revisa hazards al empezar cada tarea' \
  'Un doc que contradice al' \
  'Un test que nunca falló' \
  'afirmaciones de tamaño o rendimiento' \
  'escalaciones de producto tienen sección propia'; do
  grep -Fq "$rule" "$REPO_DIR/skills/ship-change/SKILL.md" \
    || fail "ship-change is missing leakage-prevention rule: $rule"
done

grep -Fq 'nunca `git add -A`' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not forbid staging the entire working tree'
grep -Fq 'rutas de `Files`' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not limit staging to its Files list'

for handoff_field in \
  '**Delegación (si aplica; si no, escribe `sin delegación`):**' \
  '**Agente responsable:**' \
  '**Objetivo:**' \
  '**Contexto y restricciones:**' \
  '**Rutas de escritura exclusivas:**' \
  '**Dependencias y contrato:**' \
  '**Entregable:**'; do
  grep -Fq "$handoff_field" "$REPO_DIR/skills/ship-change/references/brief.md" \
    || fail "task brief is missing delegation handoff field: $handoff_field"
done
grep -Fq 'no se solapan' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not require disjoint parallel write paths'
grep -Fq 'Una ficha por agente/entrega' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not distinguish each delegated assignment'
grep -Fq 'resumen de máximo 10 líneas' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not require a concise agent handoff'
grep -Fq 'done|blocked|partial' "$REPO_DIR/skills/ship-change/references/brief.md" \
  || fail 'task brief does not require a completion status'

grep -Fq 'No asignes rutas de escritura solapadas' "$REPO_DIR/skills/ship-change/SKILL.md" \
  || fail 'ship-change does not prevent parallel writers from owning overlapping paths'

grep -Fq 'ship-change' "$REPO_DIR/agents/developer.md" \
  || fail 'developer does not route large changes to ship-change'
grep -Fq 'developer' "$REPO_DIR/commands/ship.md" \
  || fail '/ship command does not use the developer agent'

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: SDD consumers use local skills and neutral artifact paths\n'
