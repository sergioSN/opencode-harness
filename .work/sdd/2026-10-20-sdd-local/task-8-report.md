# Task 8 report — pin SDD and setup invariants

**Result:** Strengthened contract tests to assert all six SDD leakage rules, forbid whole-tree staging, require the skills link in `scripts/link.sh`, and preserve `context7` and `codegraph` MCP declarations.

**Verification:** The real tests print:

```text
PASS: SDD consumers use local skills and neutral artifact paths
PASS: setup and operational docs are self-contained
```

Mutation fixtures removing the deferred-finding rule, staging restriction, `context7`, and the skills link each fail. Comment-only fake MCP/link entries, near-matching link paths, and an array in place of the `mcp.servers` object also fail.

**Review record:** Reviewers found Important false-positive gaps in substring/awk checks and JSON shape validation. Fixed by parsing JSONC after removing comments/trailing commas, requiring object-valued `mcp` and `mcp.servers`, and using an exact `LINKED` line match. The final reviewer verdict is **clean**, no findings; reviewers did not run tests.

**Review diffs:** `review-03b7b07..faf2c0f.diff` covers the primary contract tests; `review-faf2c0f..b80ffce.diff`, `review-b80ffce..80804fc.diff`, and `review-80804fc..e421ae1.diff` capture follow-up corrections.
