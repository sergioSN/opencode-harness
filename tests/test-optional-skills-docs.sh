#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme="$REPO_DIR/README.md"
notes="$REPO_DIR/NOTAS.md"
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

for url in \
  'https://github.com/pbakaus/impeccable' \
  'https://github.com/mattpocock/skills'; do
  grep -Fq "$url" "$readme" || fail "README.md does not reference $url"
  grep -Fq "$url" "$notes" || fail "NOTAS.md does not reference $url"
done

grep -Eqi 'opcional|opcionales' "$readme" || fail 'README.md does not label the external skills optional'
grep -Fq 'improve-codebase-architecture' "$readme" || fail 'README.md omits the optional Matt Pocock architecture skill'
grep -Fq 'triage' "$notes" || fail 'NOTAS.md omits the optional Matt Pocock triage skill'
grep -Eqi 'no hace falta instalar|no requiere.*instalar' "$readme" \
  || fail 'README.md does not say the repo works without the optional skills'
grep -Eqi 'Impeccable.{0,180}(interfaz|UI)|(interfaz|UI).{0,180}Impeccable' "$readme" \
  || fail 'README.md does not scope Impeccable to UI work'

for file in Makefile opencode.jsonc scripts/check.sh; do
  if grep -qiE 'impeccable|mattpocock/skills' "$REPO_DIR/$file"; then
    fail "$file turns an optional skills catalog into setup/config/check dependency"
  fi
done

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: optional skill references are documented without becoming dependencies\n'
