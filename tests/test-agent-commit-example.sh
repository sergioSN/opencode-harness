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

printf 'PASS: AGENTS.md requires English atomic Conventional Commits\n'
