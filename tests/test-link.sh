#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINK_SCRIPT="$SCRIPT_DIR/scripts/link.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

# A failed backup must stop before link.sh removes or replaces the original.
failed_config="$tmp_dir/config-copy-fails"
fake_bin="$tmp_dir/fake-bin"
mkdir -p "$failed_config" "$fake_bin"
failed_dst="$failed_config/opencode.jsonc"
printf 'original config\n' > "$failed_dst"
cat > "$fake_bin/cp" <<'EOF'
#!/bin/sh
exit 73
EOF
chmod +x "$fake_bin/cp"

set +e
PATH="$fake_bin:$PATH" OPENCODE_CONFIG_DIR="$failed_config" FORCE=1 \
  /bin/bash "$LINK_SCRIPT" > "$tmp_dir/copy-fails.log" 2>&1
status=$?
set -e

if [ "$status" -eq 0 ]; then
  fail "link.sh succeeded despite a failed backup copy"
fi
if [ ! -f "$failed_dst" ] || [ -L "$failed_dst" ]; then
  fail "the original destination was removed or replaced after backup failure"
fi
if [ "$(cat "$failed_dst")" != 'original config' ]; then
  fail "the original destination changed after backup failure"
fi

# A successful backup still permits the original FORCE=1 replacement flow.
normal_config="$tmp_dir/config-copy-succeeds"
mkdir -p "$normal_config"
normal_dst="$normal_config/opencode.jsonc"
printf 'replaceable config\n' > "$normal_dst"
OPENCODE_CONFIG_DIR="$normal_config" FORCE=1 /bin/bash "$LINK_SCRIPT" \
  > "$tmp_dir/copy-succeeds.log" 2>&1 \
  || fail "link.sh failed when the backup copy succeeded"

shopt -s nullglob
backups=("$normal_dst".backup-*)
if [ "${#backups[@]}" -ne 1 ]; then
  fail "expected exactly one backup, found ${#backups[@]}"
fi
if [ "$(cat "${backups[0]}")" != 'replaceable config' ]; then
  fail "the successful backup does not contain the original destination"
fi
if [ ! -L "$normal_dst" ] || [ "$(readlink -f "$normal_dst")" != "$SCRIPT_DIR/opencode.jsonc" ]; then
  fail "the destination was not replaced with the repository symlink"
fi

printf 'PASS: failed backups preserve the destination; successful backups replace it\n'
