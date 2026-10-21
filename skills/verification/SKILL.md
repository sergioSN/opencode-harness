---
name: verification
description: Use before claiming a fix, task, test suite, or release is complete or safe.
---

# Verification

Evidence before completion claims.

Before saying a task is done, identify the command that proves each claim, run it on the current tree, read its complete result and exit status, then report exactly what it establishes.

## Match claim to evidence

- **Tests pass:** run the project's full test command and report its actual count/result. A prior run, a partial suite, or a green test before the last edit is not evidence for the current tree.
- **Build/lint pass:** run their own commands; one does not substitute for another.
- **Bug fixed:** rerun the regression test that reproduced the user's symptom.
- **Config works:** parse it and verify the effective runtime state; a valid file alone does not prove it loaded.
- **No test/build command exists:** say so and report the checks that were actually run.

If a required check fails, report the failure and stop before claiming completion. Never infer success from a diff, an agent's report, or what “should” work.
