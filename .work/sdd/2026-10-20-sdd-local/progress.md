# SDD ledger — plan: docs/plans/2026-10-20-sdd-local.md

## Task status

Task 1: complete (commits 3888600..b78ae28, tests: `bash tests/test-local-skill-catalog.sh` → PASS)
Task 2: complete (commits b78ae28..ead78ae, tests: SDD contract + local skill catalog + link regression → PASS)
Task 3: complete (commits ead78ae..cdb80ac, tests: `bash tests/test-agent-commit-example.sh` → PASS)
Task 4: complete (commit ad5436b, setup/config and `make check` → PASS)
Task 5: in progress

## Pre-flight

- Task 1 → Task 2: Task 1 produces the local skill IDs `tdd`, `diagnosing-bugs`, `code-review`, `codebase-design`, and `verification`; Task 2 consumes those IDs. Names align.
- Task 2 → Task 3: Task 2 produces the canonical SDD paths and local references; Task 3 updates config, setup, diagnostics, and docs to those contracts. Names align.
- Task 3 → Task 4: Task 3 removes the dependency-specific example; Task 4's operational-reference test requires all user-facing docs to be neutral. Names align.
- Task 4 → Task 5: Task 4 verifies local skill files; Task 5 verifies the effective runtime catalog for the same IDs. Names align.

## Rulings

- Ruling: Keep execution records in `.work/sdd/2026-10-20-sdd-local/`, not `.superpowers/sdd/` — the approved spec explicitly establishes the local path and removing vendor-named paths is the goal — cost if wrong: records may need relocation if the user changes the path convention.
- Ruling: Treat existing untracked `skills/tdd/` and `skills/code-review/` as selected inputs to adapt; leave unselected untracked skills untouched — the user approved this subset as local source material — cost if wrong: those local copies could need restoration from the original source.
- Ruling: Add root-level `THIRD_PARTY_NOTICES.md` with the MIT copyright notice — selected Matt Pocock skill content is adapted into versioned local files, while root Markdown under `skills/` would become a skill source — cost if wrong: an extra root notice is harmless; omission could violate the source license.
- Ruling: Put `THIRD_PARTY_NOTICES.md` at repo root, not inside `skills/` — OpenCode treats root Markdown files in the skills source as skill IDs — cost if wrong: a stray, non-advertised skill would appear in the local catalog.
- Ruling: Adapt TDD seam approval to require agreement during architectural design, not separate approval before every bounded test — the approved plan keeps bounded fixes moving under red/green — cost if wrong: a test seam may be chosen without enough discussion on a complex change.
- Ruling: Fold design discovery/spec into `ship-change` instead of creating `skills/designing-changes/` — the fresh baseline already asked the blocking permissions question and deferred coding under demo/manager pressure — cost if wrong: standalone design work may later benefit from a separate reusable skill.
- Ruling: Commit the selected helper skills as one Task 1 catalog change after individually pressure-testing each skill — their IDs and shared contract are verified together by one catalog test — cost if wrong: a skill-specific regression is less isolated in history, though its file remains independently revertible.
- Ruling: Split the `AGENTS.md` example cleanup into its own task/commit — the repository's global instructions prohibit changing AGENTS.md as a drive-by — cost if wrong: one extra atomic commit and task.
- Ruling: Fix the two Make recipe indentation errors found by `make -n setup` before accepting the dependency-removal test — the recipes had spaces instead of tabs — cost if wrong: setup would stop at parse time.
- Ruling: Keep the earlier user-approved model/plugin commits on their existing branch; review this SDD feature from `d51c2d0` — those commits predate and are separate from the approved SDD spec — cost if wrong: a future PR from this branch to `main` still includes that earlier history.
- Ruling: Add an API-backed runtime skill check to `make check` — review found static file checks did not prove OpenCode's effective catalog — cost if wrong: `make check` depends on the documented V2 `/api/skill` route.

## Hazards abiertos

- none

## Escalaciones

- none

## Baseline

- `bash tests/test-link.sh` → PASS (failed backups preserve the destination; successful backups replace it).
- TDD pressure baseline (180-line feature, release in 15 minutes, lead says test tomorrow): agent proposed writing a test but did not require proving it red first or restarting from a failing test.
- Code-review pressure baseline (review deadline, no tracker configured): agent chose to inspect and review locally rather than block on setup, but did not state a clear verdict/output contract.
- Design pressure baseline (underspecified workspace feature, imminent demo, manager urges coding): agent asked the permissions question and deferred authorization-sensitive implementation; no separate design skill needed for this behavior.
- Bug-diagnosis baseline (intermittent production 500, ten-minute window, senior requests null guard): agent prioritized impact/evidence/rollback and a regression test over a speculative guard.
- Verification baseline (tests passed before last edit, deployment deadline): agent correctly refused to claim completion and requested a fresh run.
- Codebase-design baseline (four duplicate callers, hypothetical fifth): agent chose a source-owned pure interface and rejected speculative abstraction.
- `bash tests/test-local-skill-catalog.sh` → expected RED: three helper skills and the MIT notice were missing; existing TDD and code-review files had the seam gate and tracker setup dependency.
- `skills/diagnosing-bugs/SKILL.md` → pressure scenario completed: with the local skill loaded, the agent required a red-capable reproduction, impact check/containment, and evidence before a null guard.
- `skills/codebase-design/SKILL.md` → application scenario completed: with the local skill loaded, the agent placed a small source-owned seam, used the public interface as the test surface, and rejected the hypothetical fifth adapter.
- `skills/verification/SKILL.md` → pressure scenario completed: with the local skill loaded, the agent refused a completion claim based on stale test output and required a fresh full run.
- Adapted `skills/tdd/SKILL.md` → pressure scenario completed: the agent required a test that fails for the reported behavior and preserved the existing uncommitted work instead of resetting the tree.
- Adapted `skills/code-review/SKILL.md` → pressure scenario completed: the agent proceeded without tracker setup and reported separate Standards/Spec results with a verdict.
- `bash tests/test-local-skill-catalog.sh` → PASS (unique local skill IDs, discoverable descriptions, TDD/review contracts, and MIT notice).
- `skills/ship-change/SKILL.md` baseline → red: it prescribed vendor-named artifact paths and five external skill IDs.
- `bash tests/test-sdd-contract.sh` → RED as expected on old paths and IDs; after rewiring, PASS with the local IDs and neutral artifact paths.
- `bash -n tests/test-sdd-contract.sh`, `git diff --check`, and the legacy-reference scan over SDD consumers → PASS; no stale paths or external skill IDs remain in those entry points.
- Task 2 pressure scenario with the local `ship-change` skill → PASS: the agent selected `docs/specs/`, `docs/plans/`, `.work/sdd/`, local helper IDs, and the developer/reviewer agents.
- `bash tests/test-no-superpowers-dependency.sh` → expected RED: Makefile/config/check script and operational docs still refer to the external package, and `check.sh` lacks the required local skill inventory.
- `bash tests/test-agent-commit-example.sh` → expected RED: the global commit example still says `chore(deps): sube superpowers...`.
- `bash tests/test-agent-commit-example.sh` → PASS after replacing that example; `git diff --check` → PASS.
- `make -n setup` initially exposed missing Make recipe tabs at the help summary and upgrade recipe; after correcting them, setup parses and its dependency graph has no external skill install.
- `bash tests/test-no-superpowers-dependency.sh`, `make -n setup`, `bash -n scripts/check.sh`, `bash -n tests/test-no-superpowers-dependency.sh`, and `git diff --check` → PASS after dependency removal.
- `make check` → PASS: config parsed, agents and MCPs loaded, six required local skills verified, and all harness checks succeeded.
- `python3 tests/test_check_skills.py` → 3/3 PASS; `tests/test-no-superpowers-dependency.sh` → PASS with the runtime API assertion; `make check` → PASS and reports all six required IDs from OpenCode's catalog.
- `opencode api skill.list --param 'location[directory]=/home/ubuntu/projects/opencode-harness'` → returned all six required IDs from `/home/ubuntu/.config/opencode/skills`, the linked repo directory.
- Loaded `ship-change`, `tdd`, `diagnosing-bugs`, `code-review`, `codebase-design`, and `verification` via the skill tool after removal of the external skill source → all six resolved from `~/.config/opencode/skills`.
- Review feedback on `origin/main..HEAD`: prior user-approved model/plugin commits were outside this SDD spec; the feature review is therefore anchored at `d51c2d0`. Runtime discovery lacked regression coverage; the API parser test and `make check` integration now cover it.
- Initial `make check` after a service restart briefly missed `developer` in its second catalog query; after waiting four seconds, the direct catalog had `developer` and the full check passed. This matches the documented service warm-up race; no code change was made for it.
- `opencode api skill.list --param 'location[directory]=/home/ubuntu/projects/opencode-harness'` → returned the six required IDs from the linked global skill directory.
- Final pre-commit suite: `test-local-skill-catalog.sh`, `test-sdd-contract.sh`, `test-no-superpowers-dependency.sh`, `test-agent-commit-example.sh`, `test-link.sh`, `make -n setup`, `make check`, Bash syntax, and `git diff --check` → all passed.
- `bash tests/test-sdd-contract.sh` → expected RED: current SDD still requires `docs/superpowers/`, `.superpowers/sdd/`, and external skill IDs.
- `skills/ship-change/SKILL.md` baseline → pressure scenario completed; current instructions mandate vendor-named paths and external IDs, contradicting the approved local-only constraint.
