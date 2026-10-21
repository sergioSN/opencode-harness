### Task 4: Remove the external setup dependency

**Files:**
- Modify: `opencode.jsonc`, `Makefile`, `scripts/check.sh`, `README.md`, `NOTAS.md`, and `skills/.gitkeep`
- Test: `tests/test-no-superpowers-dependency.sh`

**Contract:**
- Remove the Superpowers plugin/source and install/check targets; preserve OpenChamber, MCPs, local skill linking, and the user's home installation.
- `make setup` and `make check` must not require the external package.
- `scripts/check.sh` validates required local skill files.

**Does not authorize:** uninstalling packages from the user's home, or changing unselected skills.

**Actual commit:** `ad5436b`.
