# Task 3 report — neutral global example

**Commit:** `cdb80ac docs(agents): neutraliza el ejemplo de dependencia`.

**Result:** Replaced only the Superpowers-specific Conventional Commit example with a neutral config-change example, honoring the repo rule that `AGENTS.md` must not be changed as a drive-by.

**Verification:** The test was observed failing on the original example, then printed:

```text
PASS: AGENTS.md uses a neutral conventional commit example
```

`git diff --check` exited 0.

**Review record:** `review-ead78ae..cdb80ac.diff` is the task diff input. Per-task verdict: **approved with findings**; the missing test output was added above. Reviewer did not execute tests.

**Deferred findings:** none.
