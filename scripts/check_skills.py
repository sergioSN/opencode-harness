#!/usr/bin/env python3
"""Valida skills requeridos en el catálogo runtime de OpenCode."""

import json
from pathlib import Path
import sys


def missing_required_skills(payload, required, expected_skill_dir):
    """Devuelve IDs ausentes o resueltos fuera del catálogo local esperado."""
    if not isinstance(payload, dict) or not isinstance(payload.get("data"), list):
        raise ValueError("la respuesta del catálogo debe contener una lista `data`")

    by_id = {}
    for item in payload["data"]:
        if (not isinstance(item, dict)
                or not isinstance(item.get("id"), str)
                or not item["id"]
                or not isinstance(item.get("path"), str)
                or not item["path"]):
            raise ValueError("cada entrada del catálogo debe incluir `id` y `path`")
        by_id.setdefault(item["id"], []).append(item)

    expected_root = Path(expected_skill_dir).resolve()
    problems = []
    for skill_id in required:
        entries = by_id.get(skill_id, [])
        if len(entries) != 1:
            problems.append(skill_id)
            continue

        path = entries[0].get("path")
        if not isinstance(path, str):
            problems.append(skill_id)
            continue

        expected_path = (expected_root / skill_id / "SKILL.md").resolve()
        try:
            actual_path = Path(path).resolve()
        except (OSError, RuntimeError):
            problems.append(skill_id)
            continue
        if actual_path != expected_path:
            problems.append(skill_id)

    return problems


def main():
    if len(sys.argv) < 3:
        print("uso: check_skills.py <directorio-local> <skill-id>...", file=sys.stderr)
        return 2

    expected_skill_dir = sys.argv[1]
    required = sys.argv[2:]
    if not required:
        print("debe indicarse al menos un ID de skill requerido", file=sys.stderr)
        return 2

    try:
        payload = json.load(sys.stdin)
        missing = missing_required_skills(payload, required, expected_skill_dir)
    except (json.JSONDecodeError, ValueError) as error:
        print("OpenCode devolvió un catálogo de skills inválido: %s" % error, file=sys.stderr)
        return 1

    if missing:
        print("OpenCode no descubrió los skills locales esperados: %s" % ", ".join(missing), file=sys.stderr)
        return 1

    print("OpenCode descubrió todos los skills locales requeridos: %s" % ", ".join(required))
    return 0


if __name__ == "__main__":
    sys.exit(main())
