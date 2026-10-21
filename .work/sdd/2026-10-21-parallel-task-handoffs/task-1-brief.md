### Task 1: Define safe delegated task handoffs

**Files:**
- Modify: `skills/ship-change/references/brief.md`
- Modify: `skills/ship-change/SKILL.md`
- Modify: `tests/test-sdd-contract.sh`
- Create: `docs/specs/2026-10-21-parallel-task-handoffs-design.md`
- Create: `docs/plans/2026-10-21-parallel-task-handoffs-plan.md`
- Create: `.work/sdd/2026-10-21-parallel-task-handoffs/{progress.md,task-1-brief.md,task-1-report.md}`

**Contract:** A serial task explicitly opts out of delegation. Every parallel assignment gets its own repeated handoff record naming the responsible agent, goal, context/constraints, exclusive write paths, dependencies/contract, and deliverable. Writer paths do not overlap; a shared verifier is read-only. Delegated reports include `done|blocked|partial`, a maximum 10-line summary, and commands/results.

**Does not authorize:** implementing a runtime agent orchestrator, automatic path inference, or editing unrelated user skills and agent files.

**Verification:** `bash tests/test-sdd-contract.sh` must fail before the template/workflow update and pass afterward.
