# Task 2 report — local SDD paths and skills

**Commit:** `ead78ae refactor(sdd): usa skills y rutas locales`.

**Result:** Replaced vendor-named artifact paths and external skill IDs in the SDD orchestrator, templates, developer agent, and `/ship` command. Preserved the six leakage-prevention rules and added the local test-first workflow.

**Verification:** `bash tests/test-sdd-contract.sh` printed:

```text
PASS: SDD consumers use local skills and neutral artifact paths
```

A pressure scenario with the local `ship-change` confirmed the local paths and agent/skill choices. After review, the contract test was strengthened to assert the six leakage-prevention rules and forbid `git add -A`; a temporary fixture with the deferred-finding rule removed was observed RED.

**Review record:** `review-b78ae28..ead78ae.diff` is the task diff input. Per-task verdict: **approved with findings**; the contract test initially omitted the six leakage rules and file-scoped staging. Assertions for both were added; a temporary fixture with the deferred-finding rule removed prints `FAIL: ship-change is missing leakage-prevention rule: Todo hallazgo diferido tiene destino`, and the actual test prints `PASS: SDD consumers use local skills and neutral artifact paths`. Reviewer did not execute tests.

**Deferred findings:** none.
