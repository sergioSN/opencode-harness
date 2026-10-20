# Task 8 report — pin SDD and setup invariants

**Result:** Strengthened contract tests to assert all six SDD leakage rules, forbid whole-tree staging, require the skills link in `scripts/link.sh`, and preserve `context7` and `codegraph` MCP declarations.

**Verification:** Both real tests pass. Mutation fixtures removing the deferred-finding rule, staging restriction, `context7`, and the skills link each fail. A fixture with comment-only fake MCP/link entries and near-matching link paths also fails.

**Review record:** First reviewer found an Important false-positive gap in substring/awk checks. A follow-up review found the replacement still accepted commented MCP blocks and unescaped path characters. Fixed by parsing JSONC after removing comments and trailing commas, then checking `mcp.servers`, and using an exact `LINKED` line match. Reviewer verdict for the final fix will be recorded before closeout.

**Review diff:** the exact range snapshot will be named after the follow-up commit is created.
