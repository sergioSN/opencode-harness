# Task 4 report — remove external setup dependency

**Commit:** `ad5436b refactor(setup): elimina la dependencia de Superpowers`.

**Result:** Removed the plugin and configured skill source, deleted the Make install target and dependency, made `setup` use local skills, and replaced external checks with checks for required local files. Updated README, NOTAS, and the skills directory guidance. No package was uninstalled.

**Ruling:** `make -n setup` exposed two Make recipes using spaces instead of tabs; corrected them to tabs because the setup target could not parse otherwise.

**Verification:** `tests/test-no-superpowers-dependency.sh` printed `PASS: setup and operational docs are self-contained`; `make -n setup`, `bash -n scripts/check.sh`, and `git diff --check` passed. The effective runtime source check was added in Task 5 after review.

**Review record:** `review-cdb80ac..ad5436b.diff` is the task diff input. Per-task verdict: **approved with findings**; its test initially omitted assertions for MCP preservation and local skill linking. The test now checks both. Mutation fixtures without `context7` and without `skills` in `LINKED` each fail; the real test passes. Reviewer did not execute tests.
