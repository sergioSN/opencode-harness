# Task 8 report — pin SDD and setup invariants

**Result:** Strengthened contract tests to assert all six SDD leakage rules, forbid whole-tree staging, require the skills link in `scripts/link.sh`, and preserve `context7` and `codegraph` MCP declarations.

**Verification:** Both real tests pass. Mutation fixtures removing the deferred-finding rule, staging restriction, `context7`, and the skills link each fail as expected.

**Review record:** The exact Task 8 diff and reviewer verdict will be recorded before closeout.
