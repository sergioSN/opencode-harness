### Task 2: Rewire SDD to local skills and paths

**Files:**
- Modify: `skills/ship-change/SKILL.md` and `skills/ship-change/references/{spec-plan,brief,ledger}.md`
- Modify: `agents/developer.md`
- Modify: `commands/ship.md`
- Test: `tests/test-sdd-contract.sh`

**Contract:**
- Specs use `docs/specs/`; plans use `docs/plans/`; task records use `.work/sdd/`.
- SDD invokes only local helper skill IDs and preserves scope, spec, plan, tasks, review, ledger, and closeout.
- Preserve all six leakage-prevention rules and use explicit file staging rather than `git add -A`.

**Does not authorize:** removing setup/config dependencies (separate task), changing unrelated skills, or pushing/publishing.

**Actual commit:** `ead78ae`.
