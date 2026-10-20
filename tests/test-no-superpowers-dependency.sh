#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${DEPENDENCY_TEST_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
operational_files=(
  Makefile
  opencode.jsonc
  scripts/check.sh
  scripts/link.sh
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
if ! python3 - "$REPO_DIR/opencode.jsonc" <<'PY'
import json
import sys
from pathlib import Path


def remove_comments(source):
    result = []
    index = 0
    quoted = False
    escaped = False
    while index < len(source):
        char = source[index]
        following = source[index + 1] if index + 1 < len(source) else ""
        if quoted:
            result.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
            index += 1
        elif char == '"':
            quoted = True
            result.append(char)
            index += 1
        elif char == "/" and following == "/":
            index += 2
            while index < len(source) and source[index] != "\n":
                index += 1
        elif char == "/" and following == "*":
            end = source.find("*/", index + 2)
            if end < 0:
                raise ValueError("unterminated JSONC block comment")
            result.extend("\n" for line in source[index:end + 2] if line == "\n")
            index = end + 2
        else:
            result.append(char)
            index += 1
    return "".join(result)


def remove_trailing_commas(source):
    result = []
    index = 0
    quoted = False
    escaped = False
    while index < len(source):
        char = source[index]
        if quoted:
            result.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
            index += 1
        elif char == '"':
            quoted = True
            result.append(char)
            index += 1
        elif char == ",":
            lookahead = index + 1
            while lookahead < len(source) and source[lookahead].isspace():
                lookahead += 1
            if lookahead < len(source) and source[lookahead] in "]}":
                index += 1
            else:
                result.append(char)
                index += 1
        else:
            result.append(char)
            index += 1
    return "".join(result)


config = json.loads(remove_trailing_commas(remove_comments(Path(sys.argv[1]).read_text())))
servers = config.get("mcp", {}).get("servers", {})
missing = {"context7", "codegraph"} - set(servers)
if missing:
    raise SystemExit("missing mcp.servers declarations: " + ", ".join(sorted(missing)))
PY
then
  fail 'context7 and codegraph must remain under mcp.servers'
fi
grep -Fxq 'LINKED=(opencode.jsonc AGENTS.md agents skills commands)' "$REPO_DIR/scripts/link.sh" \
  || fail 'the global linker no longer links the local skills directory'

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
