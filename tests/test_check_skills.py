#!/usr/bin/env python3
import sys
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from check_skills import missing_required_skills


REQUIRED = ["ship-change", "tdd", "diagnosing-bugs", "code-review", "codebase-design", "verification"]


class MissingRequiredSkillsTests(unittest.TestCase):
    def test_complete_runtime_catalog_has_no_missing_skills(self):
        payload = {"data": [{"id": skill_id} for skill_id in REQUIRED]}

        self.assertEqual([], missing_required_skills(payload, REQUIRED))

    def test_reports_required_ids_missing_from_runtime(self):
        payload = {"data": [{"id": skill_id} for skill_id in REQUIRED if skill_id != "code-review"]}

        self.assertEqual(["code-review"], missing_required_skills(payload, REQUIRED))

    def test_rejects_invalid_catalog_shape(self):
        with self.assertRaises(ValueError):
            missing_required_skills({"skills": []}, REQUIRED)


if __name__ == "__main__":
    unittest.main()
