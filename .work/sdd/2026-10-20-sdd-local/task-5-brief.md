### Task 5: Verify the effective OpenCode skill catalog

**Files:**
- Modify: `scripts/check.sh`
- Create: `scripts/check_skills.py`
- Modify: `tests/test-no-superpowers-dependency.sh`
- Create: `tests/test_check_skills.py`

**Interface:** `missing_required_skills(payload, required, expected_skill_dir)` returns IDs missing from the runtime catalog or resolved to a different source; malformed catalog payloads raise `ValueError`.

**Contract:** Query OpenCode V2's `skill.list` at the current repo location. Each required ID must resolve exactly once to `<expected_skill_dir>/<id>/SKILL.md` after symlink resolution. Missing, duplicate, malformed, or shadowed entries fail `make check`.

**Does not authorize:** changing user skill files, changing external config sources, or making optional catalogs required.

**Actual commits:** `d3b3caf` adds runtime discovery; the review fix is in the follow-up commit currently at `HEAD`.
