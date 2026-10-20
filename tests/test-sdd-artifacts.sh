#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${SDD_TEST_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
WORKSPACE="$REPO_DIR/.work/sdd/2026-10-20-sdd-local"
failures=0
declare -A primary_reviews=(
  [1]='review-3888600..b78ae28.diff'
  [2]='review-b78ae28..ead78ae.diff'
  [3]='review-ead78ae..cdb80ac.diff'
  [4]='review-cdb80ac..ad5436b.diff'
  [5]='review-ad5436b..d3b3caf.diff'
  [6]='review-d3b3caf..ffcdd84.diff'
  [7]='review-c1cbfb4..79676bf.diff'
  [8]='review-03b7b07..faf2c0f.diff'
)

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

for task in 1 2 3 4 5 6 7 8; do
  brief="$WORKSPACE/task-$task-brief.md"
  report="$WORKSPACE/task-$task-report.md"
  [ -s "$brief" ] || fail "missing task brief: ${brief#"$REPO_DIR/"}"
  if [ ! -s "$report" ]; then
    fail "missing task report: ${report#"$REPO_DIR/"}"
    continue
  fi

  reviews="$(grep -oE 'review-[[:xdigit:]]+\.\.[[:xdigit:]]+\.diff' "$report" | sort -u || true)"
  if ! grep -Fq "${primary_reviews[$task]}" "$report"; then
    fail "task $task report does not reference its primary implementation diff ${primary_reviews[$task]}"
  fi
  if [ -z "$reviews" ]; then
    fail "task $task report does not reference a review diff"
    continue
  fi
  while IFS= read -r review; do
    [ -s "$WORKSPACE/$review" ] || fail "missing review diff: $review"
  done <<<"$reviews"
done

if [ "$failures" -ne 0 ]; then
  exit 1
fi

printf 'PASS: completed SDD tasks have briefs, reports, and review diffs\n'
