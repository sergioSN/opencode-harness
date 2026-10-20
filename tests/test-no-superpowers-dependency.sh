#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
operational_files=(
  Makefile
  opencode.jsonc
  scripts/check.sh
  README.md
  NOTAS.md
  AGENTS.md
  agents/developer.md
  commands/ship.md
  skills/.gitkeep
  skills/ship-change/SKILL.md
  skills/ship-change/references/spec-plan.md
  skills/ship-change/references/brief.md
  skills/ship-change/references/ledger.md
)
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

for relative_path in "${operational_files[@]}"; do
  file="$REPO_DIR/$relative_path"
  if grep -qi 'superpowers' "$file"; then
    fail "$relative_path still mentions the external dependency"
  fi
done

grep -Fq '@openchamber/opencode-claude@1.4.1' "$REPO_DIR/opencode.jsonc" \
  || fail 'the OpenChamber plugin was removed from opencode.jsonc'

for skill_id in ship-change tdd diagnosing-bugs code-review codebase-design verification; do
  grep -Fq "$skill_id" "$REPO_DIR/scripts/check.sh" \
    || fail "check.sh does not validate local skill $skill_id"
done
grep -Fq 'opencode api skill.list' "$REPO_DIR/scripts/check.sh" \
  || fail "check.sh does not verify OpenCode's effective skill catalog"
grep -Fq 'location[directory]' "$REPO_DIR/scripts/check.sh" \
  || fail 'check.sh does not scope skill discovery to this repo'

if ! make_plan="$(cd "$REPO_DIR" && make -n setup 2>&1)"; then
  fail "make -n setup failed: $make_plan"
elif printf '%s\n' "$make_plan" | grep -qi 'superpowers'; then
  fail 'make -n setup still invokes or installs Superpowers'
fi

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: setup and operational docs are self-contained\n'
