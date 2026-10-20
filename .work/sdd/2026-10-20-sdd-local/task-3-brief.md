### Task 3: Neutralize the global dependency example

**Files:**
- Modify: `AGENTS.md` — only the Conventional Commit example
- Test: `tests/test-agent-commit-example.sh`

**Contract:**
- Remove the vendor-specific example while keeping a valid `chore(config): ...` example.
- Preserve the rest of the global instructions unchanged.

**Does not authorize:** other edits to `AGENTS.md` or changes to runtime setup.

**Actual commit:** `cdb80ac`.
