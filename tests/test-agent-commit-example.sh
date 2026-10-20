#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agents_file="$REPO_DIR/AGENTS.md"

if grep -qi 'superpowers' "$agents_file"; then
  printf 'FAIL: AGENTS.md still uses a vendor-specific dependency example\n' >&2
  exit 1
fi
if ! grep -q 'chore(config):' "$agents_file"; then
  printf 'FAIL: AGENTS.md no longer shows a conventional config example\n' >&2
  exit 1
fi

printf 'PASS: AGENTS.md uses a neutral conventional commit example\n'
