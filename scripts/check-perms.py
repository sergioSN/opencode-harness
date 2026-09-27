#!/usr/bin/env python3
"""check-perms.py — verifica los permisos de los agentes con shell restringida.

Por qué un script aparte y no unas Pipes en check.sh: porque el JSON de
`opencode debug agents` lleva acentos y comillas, y carries tres veces ya:

  1. `tr -d ' '` para aplanar borraba el espacio de `"git *"`, y el patron
     jamais casaba: falso "sin excepcion git".
  2. Medir la posicion del deny y del allow sobre el JSON entero compara el
     deny de un agente con el allow de otro, en cuanto hay mas de uno.
  3. `grep -bo` cuenta bytes y `cut -c` cuenta caracteres, asi que con acentos
     los dos offsets no son comparables.

Las tres se arreglan igual: no parsear JSON con grep. Aqui se parsea con
json.loads y se.indexa la lista de permisos, que es lo unico fiable.

Salida por stdout, una linea por resultado, para que check.sh conserve sus
colores y su contador de fallos:

    OK|texto     correcto
    BAD|texto    problema, cuenta como fallo
    WARN|texto    avisar, no cuenta como fallo
    HINT|texto    línea de ayuda a continuacion

El orden importa: gana la ULTIMA regla que coincide, asi que el deny general de
shell tiene que ir antes de las excepciones. Al reves, el deny se come el allow
y el agente existe, responde con soltura, y no puede ni hacer `git diff`.
"""
import json
import sys

# id en el catalogo -> (etiqueta legible, excepciones de shell que necesita)
ESPERADO = {
    "reviewer": ("reviewer", ["git *"]),
    "janitor": ("janitor", ["git *", "opencode session *"]),
}


def indice(perms, accion, recurso, efecto):
    """Primera posición de la regla que coincide, o None.

    Se busca la PRIMERA a propósito, no la última: el orden que importa es el
    del fichero, y es la secuencia de la lista.
    """
    for i, p in enumerate(perms):
        if (p.get("action") == accion
                and p.get("resource") == recurso
                and p.get("effect") == efecto):
            return i
    return None


def main():
    crudo = sys.stdin.read().strip()
    if not crudo:
        print("BAD|opencode debug agents no devolvió nada")
        return 1

    try:
        agentes = json.loads(crudo)
    except ValueError as e:
        print("BAD|no se pudo parsear el catálogo de agents: %s" % e)
        print("HINT|Si el formato de `opencode debug agents` ha cambiado, este")
        print("HINT|chequeo ya no vale para nada. Revisarlo antes de fiarse.")
        return 1

    if isinstance(agentes, dict):
        agentes = agentes.get("agents", [])
    if not isinstance(agentes, list):
        print("BAD|el catálogo no es una lista de agents: %s"
              % type(agentes).__name__)
        return 1

    por_id = {a.get("id"): a for a in agentes}
    fallos = 0

    for ident, (etiqueta, excepciones) in ESPERADO.items():
        agente = por_id.get(ident)

        if agente is None:
            # Lo canta ya el bucle del catalogo de check.sh; no duplicamos.
            continue

        perms = agente.get("permissions")
        if perms is None:
            print("BAD|%s no declara `permissions`: tiene los de fábrica, o sea"
                  % etiqueta)
            print("HINT|que puede escribir y ejecutar cualquier cosa.")
            fallos += 1
            continue
        if not isinstance(perms, list) or not perms:
            print("BAD|%s declara `permissions` vacío" % etiqueta)
            fallos += 1
            continue

        # 1. Que no pueda escribir ficheros.
        if indice(perms, "edit", "*", "deny") is not None:
            print("OK|%s: `edit` denegado (no puede escribir ficheros)"
                  % etiqueta)
        else:
            print("BAD|%s NO tiene `edit` denegado: podría escribir en lo que"
                  % etiqueta)
            print("HINT|controla. En agents/%s.md, permissions:" % etiqueta)
            fallos += 1

        # 2. Deny general de shell, y su posición.
        dshell = indice(perms, "shell", "*", "deny")
        if dshell is None:
            print("WARN|%s: no hay deny general de shell (revisar que no pueda"
                  % etiqueta)
            print("HINT|ejecutar nada más)")

        # 3. Cada excepción que necesita, y que vaya DESPUÉS del deny.
        for recurso in excepciones:
            aallow = indice(perms, "shell", recurso, "allow")
            if aallow is None:
                print("BAD|%s: sin la excepción `%s` en shell. No podrá ejecutar"
                      % (etiqueta, recurso))
                print("HINT|esa orden. Añádela DESPUÉS del deny general de shell:")
                print("HINT|  - action: shell / resource: \"%s\" / effect: allow"
                      % recurso)
                fallos += 1
            elif dshell is not None and dshell > aallow:
                print("BAD|%s: el deny de shell va DESPUÉS de la excepción `%s`"
                      % (etiqueta, recurso))
                print("HINT|Gana la última regla que coincide, así que el deny se")
                print("HINT|come el allow y no puede ejecutar esa orden.")
                fallos += 1
            else:
                print("OK|%s: shell denegado salvo `%s` (orden correcto)"
                      % (etiqueta, recurso))

    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
