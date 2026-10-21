# Task 1 report — safe delegated task handoffs

**Result:** Added an optional delegation block to the brief template and coordination rules to `ship-change`. Parallel assignments identify an agent, goal, context/constraints, exclusive write paths, dependencies/contract, and deliverable. Writer paths cannot overlap; read-only verification may share paths. Delegated results use `done|blocked|partial`, a summary up to 10 lines, and commands/results.

**TDD evidence:** Before the docs changed, `bash tests/test-sdd-contract.sh` failed on the absent delegation fields, disjoint-path rule, concise handoff, status, and coordinator instruction. After implementation it prints `PASS: SDD consumers use local skills and neutral artifact paths`.

**Verification:** `bash tests/test-local-skill-catalog.sh` prints `PASS: required local skills have unique, discoverable definitions`; `bash tests/test-no-superpowers-dependency.sh` prints `PASS: setup and operational docs are self-contained`; `make check` ends with `✓ Todo correcto.` Scoped `git diff --check` and `bash -n tests/test-sdd-contract.sh` pass.

**Review:** Initial reviewer verdict: **approved with findings**. It found two missing regression assertions (shared read-only paths and command/result evidence); both were added. Follow-up verdict: **clean**, no findings. Reviewers did not run tests.

**Review diffs:** `review-20d5e3b..00e6420.diff` is the initial implementation; `review-20d5e3b..1d8b989.diff` includes the coverage follow-up.
