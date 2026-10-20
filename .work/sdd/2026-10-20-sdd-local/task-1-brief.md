### Task 1: Add the local helper-skill catalog

**Files:**
- Modify: `skills/tdd/SKILL.md` and its selected support files
- Modify: `skills/code-review/SKILL.md`
- Create: `skills/diagnosing-bugs/SKILL.md`
- Create: `skills/codebase-design/SKILL.md`
- Create: `skills/verification/SKILL.md`
- Create: `THIRD_PARTY_NOTICES.md`
- Test: `tests/test-local-skill-catalog.sh`

**Contract:**
- The five required skill IDs have one discoverable local `SKILL.md` each.
- TDD retains red-before-green without imposing a separate approval for every bounded test.
- Code review uses the local reviewer and does not require issue-tracker setup.
- Adapted Matt Pocock material retains the MIT notice.

**Does not authorize:**
- Importing the full Matt Pocock catalog or editing unselected skills such as `triage`.
- Adding an external skill installation or issue-tracker dependency.

**Actual commit:** `b78ae28`.
