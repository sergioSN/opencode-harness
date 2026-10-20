#!/usr/bin/env python3
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, os.environ.get(
    "CHECK_SKILLS_DIR",
    str(Path(__file__).resolve().parents[1] / "scripts"),
))

from check_skills import missing_required_skills


REQUIRED = ["ship-change", "tdd", "diagnosing-bugs", "code-review", "codebase-design", "verification"]


class MissingRequiredSkillsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.local_skills = self.root / "local-skills"
        for skill_id in REQUIRED:
            skill_dir = self.local_skills / skill_id
            skill_dir.mkdir(parents=True)
            (skill_dir / "SKILL.md").write_text("---\nname: %s\n---\n" % skill_id)

    def catalog(self):
        return {"data": [
            {"id": skill_id, "path": str(self.local_skills / skill_id / "SKILL.md")}
            for skill_id in REQUIRED
        ]}

    def test_complete_runtime_catalog_has_no_missing_skills(self):
        self.assertEqual([], missing_required_skills(self.catalog(), REQUIRED, self.local_skills))

    def test_reports_required_ids_missing_from_runtime(self):
        payload = self.catalog()
        payload["data"] = [item for item in payload["data"] if item["id"] != "code-review"]

        self.assertEqual(["code-review"], missing_required_skills(payload, REQUIRED, self.local_skills))

    def test_reports_local_skill_shadowed_by_another_catalog(self):
        payload = self.catalog()
        elsewhere = self.root / "other-skills" / "code-review" / "SKILL.md"
        elsewhere.parent.mkdir(parents=True)
        elsewhere.write_text("---\nname: code-review\n---\n")
        next(item for item in payload["data"] if item["id"] == "code-review")["path"] = str(elsewhere)

        self.assertEqual(["code-review"], missing_required_skills(payload, REQUIRED, self.local_skills))

    def test_reports_duplicate_runtime_id_as_ambiguous(self):
        payload = self.catalog()
        duplicate = dict(payload["data"][0])
        duplicate["path"] = str(self.root / "other-skills" / "ship-change" / "SKILL.md")
        payload["data"].append(duplicate)

        self.assertEqual(["ship-change"], missing_required_skills(payload, REQUIRED, self.local_skills))

    def test_rejects_invalid_catalog_shape(self):
        with self.assertRaises(ValueError):
            missing_required_skills({"skills": []}, REQUIRED, self.local_skills)

    def test_rejects_malformed_catalog_entry_even_when_required_ids_exist(self):
        malformed_entries = [
            {"name": "skill without an ID", "path": "/external/SKILL.md"},
            {"id": "external-skill"},
        ]
        for malformed in malformed_entries:
            with self.subTest(malformed=malformed):
                payload = self.catalog()
                payload["data"].append(malformed)
                with self.assertRaises(ValueError):
                    missing_required_skills(payload, REQUIRED, self.local_skills)


if __name__ == "__main__":
    unittest.main()
