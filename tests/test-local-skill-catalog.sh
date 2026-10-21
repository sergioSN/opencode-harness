#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
required=(tdd diagnosing-bugs code-review codebase-design verification)
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

for skill_id in "${required[@]}"; do
  skill_file="$SKILLS_DIR/$skill_id/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    fail "missing local skill: $skill_id"
    continue
  fi

  if ! grep -q "^name: $skill_id$" "$skill_file"; then
    fail "$skill_id has no matching name in frontmatter"
  fi
  if ! grep -q '^description: .\+' "$skill_file"; then
    fail "$skill_id has no discoverable description"
  fi

  matches="$(grep -RIl --include=SKILL.md "^name: $skill_id$" "$SKILLS_DIR" || true)"
  count="$(printf '%s\n' "$matches" | sed '/^$/d' | wc -l)"
  if [ "$count" -ne 1 ]; then
    fail "$skill_id has $count local definitions; expected exactly one"
  fi
done

tdd_file="$SKILLS_DIR/tdd/SKILL.md"
if [ -f "$tdd_file" ]; then
  grep -q 'Red before green' "$tdd_file" || fail 'tdd does not require red before green'
  grep -q 'No test is written at an unconfirmed seam' "$tdd_file" && fail 'tdd requires a separate user approval before every test seam'
fi

review_file="$SKILLS_DIR/code-review/SKILL.md"
if [ -f "$review_file" ]; then
  grep -q 'reviewer' "$review_file" || fail 'code-review is not adapted to the local reviewer agent'
  grep -q 'setup-matt-pocock-skills' "$review_file" && fail 'code-review still requires Matt Pocock tracker setup'
fi

notice="$REPO_DIR/THIRD_PARTY_NOTICES.md"
if [ ! -f "$notice" ] || ! grep -q 'MIT License' "$notice" || ! grep -q 'Copyright (c) 2026 Matt Pocock' "$notice"; then
  fail "missing MIT attribution for adapted Matt Pocock skills"
fi

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: required local skills have unique, discoverable definitions\n'
