### Task 7: Reject malformed runtime skill entries

**Files:**
- Modify: `scripts/check_skills.py`
- Test: `tests/test_check_skills.py`

**Contract:** Reject any catalog `data` entry without a nonempty string `id` and `path`, even when all required valid IDs are present. Keep the existing missing-ID, duplicate-ID, and local-source checks.

**Does not authorize:** changing required skill IDs, touching optional skills, or changing OpenCode configuration.

**Verification:** Run the malformed-entry test against the committed pre-fix parser, then run the parser suite against the corrected implementation.
