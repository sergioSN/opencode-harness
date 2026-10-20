# Task 8 report — pin SDD and setup invariants

**Result:** Strengthened contract tests to assert all six SDD leakage rules, forbid whole-tree staging, require the skills link in `scripts/link.sh`, and preserve `context7` and `codegraph` MCP declarations.

**Verification:** The real tests print:

```text
PASS: SDD consumers use local skills and neutral artifact paths
PASS: setup and operational docs are self-contained
```

Mutation fixtures removing the deferred-finding rule, staging restriction, `context7`, and the skills link each fail. Comment-only fake MCP/link entries, near-matching link paths, and an array in place of the `mcp.servers` object also fail.

**Review record:** Reviewers found successive Important false-positive gaps in substring/awk checks and JSON shape validation. Fixed by parsing JSONC after removing comments/trailing commas, requiring object-valued `mcp` and `mcp.servers`, and using an exact `LINKED` line match. The first follow-up snapshot is `review-b80ffce..80804fc.diff`; its reviewer requested object-type validation and an updated report. Final verdict will be recorded after the fix review.

**Review diff:** `review-b80ffce..80804fc.diff` plus the final validation follow-up snapshot.
