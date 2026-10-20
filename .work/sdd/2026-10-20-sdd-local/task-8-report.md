# Task 8 report — pin SDD and setup invariants

**Result:** Strengthened contract tests to assert all six SDD leakage rules, forbid whole-tree staging, require the skills link in `scripts/link.sh`, and preserve `context7` and `codegraph` MCP declarations.

**Verification:** Both real tests pass. Mutation fixtures removing the deferred-finding rule, staging restriction, `context7`, and the skills link each fail. A follow-up fixture with comment-only fake MCP/link entries also fails, so comments cannot satisfy the checks.

**Review record:** Reviewer found an Important false-positive gap: MCP/link checks matched substrings outside their intended structures. Fixed by scoping MCP assertions beneath `mcp.servers` and matching the exact `LINKED` declaration. The follow-up diff and reviewer verdict will be recorded before closeout.
