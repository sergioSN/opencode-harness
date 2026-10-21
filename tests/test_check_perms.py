#!/usr/bin/env python3
import json
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CHECK_PERMS = ROOT / "scripts" / "check-perms.py"


def permissions(*rules):
    return [
        {"action": action, "resource": resource, "effect": effect}
        for action, resource, effect in rules
    ]


def catalog(reviewer_permissions=None, janitor_permissions=None):
    reviewer = reviewer_permissions if reviewer_permissions is not None else permissions(
        ("edit", "*", "deny"),
        ("shell", "*", "deny"),
        ("shell", "git *", "allow"),
    )
    janitor = janitor_permissions if janitor_permissions is not None else permissions(
        ("edit", "*", "deny"),
        ("shell", "*", "deny"),
        ("shell", "git *", "allow"),
        ("shell", "opencode session *", "allow"),
    )
    return [
        {"id": "reviewer", "permissions": reviewer},
        {"id": "janitor", "permissions": janitor},
    ]


def check(payload):
    return subprocess.run(
        [sys.executable, str(CHECK_PERMS)],
        input=json.dumps(payload),
        text=True,
        capture_output=True,
        check=False,
    )


class RestrictedAgentPermissionsTests(unittest.TestCase):
    def test_valid_reviewer_and_janitor_permissions_pass(self):
        result = check(catalog())

        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_missing_general_shell_deny_fails_check(self):
        unsafe_reviewer = permissions(
            ("edit", "*", "deny"),
            ("shell", "git *", "allow"),
        )
        unsafe_janitor = permissions(
            ("edit", "*", "deny"),
            ("shell", "git *", "allow"),
            ("shell", "opencode session *", "allow"),
        )

        result = check(catalog(reviewer_permissions=unsafe_reviewer))
        janitor_result = check(catalog(janitor_permissions=unsafe_janitor))

        self.assertNotEqual(0, result.returncode)
        self.assertIn("BAD|reviewer", result.stdout)
        self.assertIn("no hay deny general de shell", result.stdout)
        self.assertNotEqual(0, janitor_result.returncode)
        self.assertIn("BAD|janitor", janitor_result.stdout)
        self.assertIn("no hay deny general de shell", janitor_result.stdout)

    def test_exception_after_deny_remains_required(self):
        wrong_order = permissions(
            ("edit", "*", "deny"),
            ("shell", "git *", "allow"),
            ("shell", "*", "deny"),
        )

        result = check(catalog(reviewer_permissions=wrong_order))

        self.assertNotEqual(0, result.returncode)
        self.assertIn("el deny de shell va DESPUÉS", result.stdout)


if __name__ == "__main__":
    unittest.main()
