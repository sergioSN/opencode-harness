#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

grep -Fq 'ship-change' "$REPO_DIR/agents/developer.md" \
  || fail 'developer does not route large changes to ship-change'
grep -Fq 'developer' "$REPO_DIR/commands/ship.md" \
  || fail '/ship command does not use the developer agent'

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: SDD consumers use local skills and neutral artifact paths\n'
