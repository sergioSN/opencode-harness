### Task 8: Pin reviewed SDD and setup invariants

**Files:**
- Modify: `tests/test-sdd-contract.sh`
- Modify: `tests/test-no-superpowers-dependency.sh`

**Contract:** The SDD contract test must detect removal of any of the six leakage-prevention rules and the file-scoped staging restriction. The setup test must detect removal of the linked local `skills/` directory or either configured MCP (`context7`, `codegraph`).

**Does not authorize:** production behavior changes, config edits, changes to user skills, or broad staging.

**Verification:** Run each test normally and with temporary fixtures missing an invariant; normal fixtures pass and each mutation fails.
