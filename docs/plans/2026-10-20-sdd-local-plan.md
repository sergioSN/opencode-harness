# SDD local implementation plan

> **For implementation agents:** Work task by task using the local `skills/ship-change` flow and local `tdd` skill. Do not invoke Superpowers or depend on externally installed skill IDs. Steps use checkbox syntax for tracking.

**Goal:** Remove the harness's operational dependency on Superpowers while preserving its SDD workflow and making the skills and artifact paths local and versioned.

**Architecture:** Keep `/ship` and `skills/ship-change` as the SDD entry point/orchestrator. Add a curated local helper-skill set, then rewire SDD templates and agents to those IDs and neutral paths. Finally remove the external package, config, setup and check assumptions while preserving unrelated user-installed skills and plugins.

**Tech Stack:** OpenCode V2, Markdown skill files, JSONC configuration, GNU Make, Bash.

**Spec:** `docs/specs/2026-10-20-sdd-local-design.md`

## Global Constraints

- Keep `/ship` and `skills/ship-change` as the SDD entry point and orchestrator.
- Preserve SDD phases, task briefs, reports, reviews, ledger, and the six existing leakage-prevention rules.
- Use `docs/specs/`, `docs/plans/`, and `.work/sdd/` for new artifacts; keep `.work/sdd/` versioned.
- Remove operational Superpowers installation/configuration/references; do not uninstall `~/.local/share/superpowers`.
- Keep the OpenChamber plugin, MCP configuration, and unrelated untracked skills unchanged.
- Adapt only the selected Matt Pocock practices; do not import his complete catalog or tracker setup.

## Review Focus

- OpenCode may stop discovering local skills after the explicit external `skills` source is removed; Task 3 verifies discovery through the linked global skills directory.
- A later skill source may shadow a local ID such as `tdd`; Task 1 checks the local catalog and Task 3 checks the effective runtime catalog.
- A consumer may retain an external skill ID or old output path; Task 2 tests all SDD entry points and templates for local IDs and paths.
- Setup or diagnostics may still install or require Superpowers through an indirect target; Task 3 checks the Make dependency graph and operational files.
- `.work/sdd/` or user-installed skills may be ignored, deleted, or accidentally staged; Task 2 verifies the artifact path is not ignored and all tasks limit staging to owned files.

---

### Task 1: Add the local helper-skill catalog

**Files:**
- Modify: `skills/tdd/SKILL.md` to align seam approval with the local SDD flow
- Keep: `skills/tdd/tests.md`, `skills/tdd/mocking.md`, `skills/tdd/agents/openai.yaml` as supporting parts of the selected local TDD skill
- Create: `skills/diagnosing-bugs/SKILL.md`
- Modify: `skills/code-review/SKILL.md` and adapt its local reviewer invocation; preserve useful existing content
- Keep: `skills/code-review/agents/openai.yaml` as selected skill metadata
- Create: `skills/codebase-design/SKILL.md`
- Create: `skills/verification/SKILL.md`
- Create: `THIRD_PARTY_NOTICES.md`
- Test: `tests/test-local-skill-catalog.sh`

**Interfaces:**
- Consumes: the existing local `skills/tdd/` files and the approved SDD spec.
- Produces: discoverable skill IDs `tdd`, `diagnosing-bugs`, `code-review`, `codebase-design`, and `verification`. `tdd` and `code-review` already exist as user-provided local files; adapt them in place. `ship-change` can load these exact IDs in Task 2; design/spec remains inside `ship-change`.

- [x] **Step 1: Write the failing catalog test.** Assert that each required ID has exactly one `SKILL.md`, valid `name` and `description` frontmatter, and no duplicate ID among the local skill directories. Assert TDD retains red-before-green without requiring user approval before every test, code review uses the local `reviewer` without tracker setup, and the attribution notice includes Matt Pocock's MIT copyright.
- [x] **Step 2: Run `bash tests/test-local-skill-catalog.sh`.** Expected: FAIL for the missing local skills and MIT notice, and for the current TDD seam gate and tracker setup requirement; confirm `tdd` and `code-review` files are detected.
- [x] **Step 3: Add/adapt the local skills.** Use Matt Pocock's selected practices as editable source material, not a runtime dependency; preserve the MIT copyright notice for adapted content. Keep design/spec inside `ship-change`; preserve behavior-focused tests and red/green. Agree on important test seams during design for architectural work, but do not require a separate user approval before every test in a bounded fix. Adapt `code-review` to the existing `reviewer` agent and remove its issue-tracker/setup requirement. Leave `triage` and other unselected skills untouched.
- [x] **Step 4: Run `bash tests/test-local-skill-catalog.sh`.** Expected: PASS, one valid local definition per required ID.
- [x] **Step 5: Run `git diff --check` and review the selected skill files.** Expected: no whitespace errors; include all supporting files for `tdd` and `code-review`, and leave unrelated untracked skills unchanged.
- [x] **Step 6: Commit** as `feat(skills): añade prácticas locales de ingeniería`.

### Task 2: Rewire SDD to local skills and paths

**Files:**
- Modify: `skills/ship-change/SKILL.md`
- Modify: `skills/ship-change/references/spec-plan.md`
- Modify: `skills/ship-change/references/brief.md`
- Modify: `skills/ship-change/references/ledger.md`
- Modify: `agents/developer.md`
- Modify: `commands/ship.md`
- Test: `tests/test-sdd-contract.sh`

**Interfaces:**
- Consumes: Task 1 skill IDs `tdd`, `diagnosing-bugs`, `code-review`, `codebase-design`, and `verification`.
- Produces: the local SDD contract and artifact paths consumed by Task 3 and future `/ship` runs.

- [x] **Step 1: Write the failing SDD contract test.** Assert that the command and developer route large changes to `ship-change`; that the SDD skill names its local helper IDs and preserves scope → spec → plan → tasks → review → ledger → closeout; that templates use `docs/specs/`, `docs/plans/`, and `.work/sdd/` rather than vendor-named paths; and that `.work/sdd/` is not ignored by the repo.
- [x] **Step 2: Run `bash tests/test-sdd-contract.sh`.** Expected: FAIL on the current external skill IDs and `docs/superpowers/` / `.superpowers/sdd/` paths.
- [x] **Step 3: Update the SDD instructions and templates.** Keep the six leakage-prevention rules, per-task verification/review, hazard ownership, escalation section, and one-task/one-commit discipline. Replace external IDs with Task 1 IDs or inline SDD-specific work in `ship-change`.
- [x] **Step 4: Run `bash tests/test-sdd-contract.sh`.** Expected: PASS; all consumers and templates agree on the local IDs and exact paths.
- [x] **Step 5: Run `git diff --check` and review the SDD references as a whole.** Expected: no stale operational path or missing lifecycle phase.
- [x] **Step 6: Commit** as `refactor(sdd): usa skills y rutas locales`.

### Task 3: Neutralize the dependency example in global instructions

**Files:**
- Modify: `AGENTS.md`
- Test: `tests/test-agent-commit-example.sh`

**Interfaces:**
- Consumes: the project's Conventional Commit examples.
- Produces: a neutral commit example; Task 4 removes the remaining operational dependency without mixing this file into another commit.

- [x] **Step 1: Write the failing example test.** Assert the global instructions no longer use a Superpowers-specific dependency example and still show a valid conventional config-change example.
- [x] **Step 2: Run `bash tests/test-agent-commit-example.sh`.** Expected: FAIL on the current `chore(deps): sube superpowers...` example.
- [x] **Step 3: Replace only that example** with a neutral agent/config example; preserve all other global instructions.
- [x] **Step 4: Run the example test and `git diff --check`.** Expected: PASS.
- [x] **Step 5: Commit** as `docs(agents): neutraliza el ejemplo de dependencia`.

### Task 4: Remove the external setup dependency

**Files:**
- Modify: `opencode.jsonc`
- Modify: `Makefile`
- Modify: `scripts/check.sh`
- Modify: `README.md`
- Modify: `NOTAS.md`
- Modify: `skills/.gitkeep`
- Test: `tests/test-no-superpowers-dependency.sh`

**Interfaces:**
- Consumes: Task 1 local skill catalog, Task 2 SDD IDs/paths, and Task 3's neutral global instructions.
- Produces: setup and diagnostics that no longer require the external package, plugin, path, or skill count.

- [x] **Step 1: Write the failing dependency-removal test.** Check operational config, Make targets, setup dependency graph, and check script for external package/path requirements; assert the OpenChamber plugin remains configured and setup still links local `skills/`.
- [x] **Step 2: Run `bash tests/test-no-superpowers-dependency.sh`.** Expected: FAIL on the current plugin, external skill source, Make target, and checks.
- [x] **Step 3: Remove the external dependency.** Delete only the external plugin/source and installation variables/target; make `setup` independent of it; replace external checks with required local-skill checks; update help and docs. Do not remove anything from the user's home directory or alter unrelated skills/plugins.
- [x] **Step 4: Run `bash tests/test-no-superpowers-dependency.sh`.** Expected: PASS; external setup/config checks are absent and local setup remains declared.
- [x] **Step 5: Run `make -n setup`, `bash tests/test-link.sh`, `bash -n scripts/check.sh`, and `git diff --check`.** Expected: setup's dependency graph contains no external skill install; regression test, syntax, and whitespace checks pass.
- [x] **Step 6: Verify OpenCode V2 config and local skill discovery.** Confirm config parses, OpenChamber remains configured, and the required skills load from the linked global directory.
- [x] **Step 7: Run `make check`.** Expected: harness checks pass without requiring an external skill source.
- [x] **Step 8: Commit** as `refactor(setup): elimina la dependencia de Superpowers`.

### Task 5: Verify the effective OpenCode skill catalog

**Files:**
- Modify: `scripts/check.sh`
- Modify: `tests/test-no-superpowers-dependency.sh`
- Create: `scripts/check_skills.py`
- Test: `tests/test_check_skills.py`

**Interfaces:**
- Consumes: Task 1's required local skill IDs and OpenCode V2's `GET /api/skill` response for the current directory.
- Produces: `missing_required_skills(payload, required, expected_skill_dir)`, which returns IDs missing from the runtime catalog or resolved to another source, and raises `ValueError` for an invalid response.

- [x] **Step 1: Extend the dependency test** to require `check.sh` to query `opencode api skill.list` with the current project location.
- [x] **Step 2: Run `bash tests/test-no-superpowers-dependency.sh`.** Expected: FAIL because the runtime query is not present.
- [x] **Step 3: Write the parser unit test** for a complete API payload, a missing required ID, an invalid response, and a same-ID skill resolved from a different directory.
- [x] **Step 4: Run `python3 tests/test_check_skills.py`.** Expected: RED because the helper does not yet accept or validate the expected local skill directory.
- [x] **Step 5: Implement the parser and runtime check.** Resolve each API path and compare it with `<expected_skill_dir>/<id>/SKILL.md`; keep static file checks and surface API, missing-ID, and shadowed-source failures through `check.sh`.
- [x] **Step 6: Run the parser and dependency tests.** Expected: PASS; absent and shadowed skills fail even when same-ID files exist elsewhere.
- [x] **Step 7: Verify the live API** returns all required skill IDs for this repo, then run `make check`. Expected: all local skills are found and the harness gate passes.
- [x] **Step 8: Commit** as `fix(check): verifica skills en el catálogo de OpenCode`.

### Task 6: Document optional companion skill catalogs

**Files:**
- Modify: `README.md`
- Modify: `NOTAS.md`
- Modify: `docs/specs/2026-10-20-sdd-local-design.md`
- Test: `tests/test-optional-skills-docs.sh`

**Interfaces:**
- Consumes: local required skill catalog from Tasks 1 and 5.
- Produces: user-facing distinction between required local skills and optional external catalogs; no installation/configuration dependency is added.

- [x] **Step 1: Write the failing docs contract test.** Require links to Impeccable and Matt Pocock in README and notes, an optional label, the optional `improve-codebase-architecture` skill, a statement the repo works without installing these catalogs, Impeccable scoped to UI, and no external entries in setup/config/check.
- [x] **Step 2: Run `bash tests/test-optional-skills-docs.sh`.** Expected: FAIL because the README does not yet document these optional companions.
- [x] **Step 3: Update README and NOTAS.** Explain the local SDD remains self-contained; mention Matt's optional `improve-codebase-architecture`/`triage` and the Impeccable UI-design skill by upstream link. Do not claim the harness itself has a UI or add install commands, packages, plugins, or config entries.
- [x] **Step 4: Run the docs contract test and `git diff --check`.** Expected: PASS and no whitespace issues.
- [x] **Step 5: Commit** as `docs(readme): menciona skills opcionales`.

### Task 7: Reject malformed runtime skill entries

**Files:**
- Modify: `scripts/check_skills.py`
- Test: `tests/test_check_skills.py`

**Interfaces:**
- Consumes: OpenCode's skill API payload.
- Produces: a strict parser that rejects any catalog entry missing a nonempty string `id` or `path`, even when all required IDs otherwise appear.

- [x] **Step 1: Write malformed-entry tests** where the payload contains every required valid skill plus entries with missing, empty, or non-string `id`/`path` fields.
- [x] **Step 2: Run `python3 tests/test_check_skills.py` against the current committed parser.** Expected: FAIL because the malformed entry is silently ignored.
- [x] **Step 3: Reject malformed entries** in `missing_required_skills` before comparing IDs and source paths.
- [x] **Step 4: Run `python3 tests/test_check_skills.py`.** Expected: all parser cases pass.
- [x] **Step 5: Commit** as `fix(check): rechaza entradas malformadas del catálogo`.

### Task 8: Pin the reviewed SDD and setup invariants

**Files:**
- Modify: `tests/test-sdd-contract.sh`
- Modify: `tests/test-no-superpowers-dependency.sh`

**Interfaces:**
- Consumes: the local SDD rules and the setup/configuration contract.
- Produces: regression tests that fail if any of the six leakage-prevention rules or safe local-link/MCP setup invariants are removed.

- [x] **Step 1: Extend the SDD contract test** to assert all six leakage-prevention rules and forbid `git add -A` while requiring staging only `Files` paths.
- [x] **Step 2: Extend the setup contract test** to assert the local skills directory remains in the global link set and both `context7` and `codegraph` remain configured.
- [x] **Step 3: Run mutation checks** with temporary copies missing one SDD rule, the skills link, and one MCP; each mutated fixture must fail.
- [x] **Step 4: Run the real SDD and setup contract tests.** Expected: both pass on the repository files.
- [x] **Step 5: Commit** as `test(sdd): cubre invariantes del flujo local`.

### Task 9: Backfill per-task SDD traceability

**Files:**
- Create: `.work/sdd/2026-10-20-sdd-local/task-{1..8}-brief.md`
- Create: `.work/sdd/2026-10-20-sdd-local/task-{1..8}-report.md`
- Create: `.work/sdd/2026-10-20-sdd-local/review-<commit-range>.diff`
- Create: `tests/test-sdd-artifacts.sh`

**Interfaces:**
- Consumes: commits for Tasks 1–8, the approved spec, and the implementation plan.
- Produces: versioned, auditable task briefs, execution reports, and exact diff inputs for task reviews; reports state clearly when review was aggregate or retrospective.

- [x] **Step 1: Write the artifact completeness test.** Require each completed task 1–8 to have a nonempty brief, report, and every review diff referenced by its report.
- [x] **Step 2: Run `bash tests/test-sdd-artifacts.sh`.** Expected: RED because per-task artifacts are missing.
- [x] **Step 3: Backfill briefs and reports** from the approved plan and actual commit history; record only observed verification results and review verdicts, never invent task-level reviews.
- [x] **Step 4: Generate exact diff snapshots** for each task's commit range and the Task 5 review-fix commit; record the commit mapping in each report.
- [x] **Step 5: Run `bash tests/test-sdd-artifacts.sh` and inspect each report/diff pairing.** Expected: PASS; every completed task report points to an existing diff snapshot.
- [x] **Step 6: Commit** as `docs(sdd): completa artefactos por tarea`.

## Final gate

- [x] Run the six shell contract tests, `tests/test-link.sh`, and `python3 tests/test_check_skills.py`.
- [x] Run Bash/Python syntax checks and scoped whitespace checks for changed source/docs; exclude unrelated dirty agent files and immutable exact-review `.diff` snapshots (which preserve upstream whitespace) from whitespace lint.
- [x] Read the full SDD range diff; confirm unrelated untracked skills and the local Superpowers installation remain untouched.
- [x] Run `make check` and verify the local skills in OpenCode V2.
- [x] Review the complete SDD range `d51c2d0..1eec050` against `docs/specs/2026-10-20-sdd-local-design.md`; all Spec findings were resolved. Standards review found two minor documentation issues, fixed in this closeout.
