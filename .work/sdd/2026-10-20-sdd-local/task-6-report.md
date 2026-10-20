# Task 6 report — optional skill recommendations

**Commit:** `ffcdd84 docs(readme): menciona skills opcionales`.

**Result:** README and NOTES link to Matt Pocock and Impeccable, explain their complementary uses, and state they are optional. The local SDD and setup continue to use versioned local skills without either installation.

**Verification:** The docs contract test printed:

```text
PASS: optional skill references are documented without becoming dependencies
```

`tests/test-no-superpowers-dependency.sh` remained green, confirming no runtime dependency was introduced.

**Review record:** `review-d3b3caf..ffcdd84.diff` is the task diff input. Per-task verdict: **clean**, no findings. Reviewer did not execute tests; the docs and dependency tests ran in the implementation session.

**Deferred findings:** none.
