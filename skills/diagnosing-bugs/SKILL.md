---
name: diagnosing-bugs
description: Use when a bug is intermittent, hard to reproduce, crosses several layers, returns wrong output, or causes a performance regression.
---

# Diagnosing Bugs

## Core rule

Find the cause before changing production behavior. For a difficult bug, the first deliverable is a fast, repeatable signal that turns red on the reported symptom.

## Workflow

1. **Bound the symptom.** Capture the exact error, output, timing, affected path, and recent changes. Redact secrets and personal data.
2. **Build the feedback loop.** Prefer a regression test at the real call site; otherwise use the narrowest CLI, HTTP, replay, or throwaway harness that exercises the failing path. Assert the user's symptom, not just that the process exits.
3. **Reproduce and minimize.** Run the loop, reduce inputs and layers one at a time, and retain only what is necessary to keep it red. For intermittent failures, raise the reproduction rate and pin time, randomness, network, and filesystem state where possible.
4. **Form falsifiable hypotheses.** For a complex issue, list a few ranked causes and the observation each predicts. Instrument only the boundary that distinguishes them; remove temporary diagnostics when done.
5. **Fix at the cause.** Use `tdd` for a regression test at the correct behavior seam, watch it fail, make the smallest fix, then watch it pass. If no correct test seam exists, report that limitation instead of claiming the bug is locked down.
6. **Re-run the original loop.** Confirm the minimized regression test and the original symptom are both green. For performance issues, compare against a measured baseline.

## If the loop cannot be built

Stop before guessing. State what was attempted and request the missing redacted log, trace, request, environment access, or permission needed to build a reproducible signal. If impact is rising, use the project's established containment or rollback procedure while diagnosis continues.

## Guardrails

- Do not add a plausible guard before evidence identifies the invalid state and its intended behavior.
- Do not log everything; each probe must distinguish a stated hypothesis.
- Do not leave debug instrumentation or throwaway harnesses in the shipped change.
- Do not claim a fix from a green test that never reproduced the reported failure.
