#!/usr/bin/env python3
"""Valida skills requeridos en el catálogo runtime de OpenCode."""

import json
import sys


def missing_required_skills(payload, required):
    """Devuelve IDs requeridos ausentes en una respuesta GET /api/skill."""
    if not isinstance(payload, dict) or not isinstance(payload.get("data"), list):
        raise ValueError("la respuesta del catálogo debe contener una lista `data`")

    discovered = {
        item.get("id")
        for item in payload["data"]
        if isinstance(item, dict) and isinstance(item.get("id"), str)
    }
    return [skill_id for skill_id in required if skill_id not in discovered]


def main():
    required = sys.argv[1:]
    if not required:
        print("debe indicarse al menos un ID de skill requerido", file=sys.stderr)
        return 2

    try:
        payload = json.load(sys.stdin)
        missing = missing_required_skills(payload, required)
    except (json.JSONDecodeError, ValueError) as error:
        print("OpenCode devolvió un catálogo de skills inválido: %s" % error, file=sys.stderr)
        return 1

    if missing:
        print("OpenCode no descubrió los skills requeridos: %s" % ", ".join(missing), file=sys.stderr)
        return 1

    print("OpenCode descubrió todos los skills locales requeridos: %s" % ", ".join(required))
    return 0


if __name__ == "__main__":
    sys.exit(main())
