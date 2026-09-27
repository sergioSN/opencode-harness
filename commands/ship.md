---
description: Lanza el bucle completo de un cambio (spec, plan, tareas, código, docs y tests en verde) con el agente developer
agent: developer
---

Estado actual del repositorio:

!`git status --short && git log --oneline -10 && git branch --show-current`

Quiero este cambio:

$ARGUMENTS

Sigue el bucle del agente developer. Si el cambio es una feature multi-archivo,
una migración o va a ocupar más de una sesión, carga el skill `ship-change` y haz
el SDD completo con spec, plan, tareas y ledger.

Antes de escribir nada, dime en una frase qué comandos de test, build y lint vas a
usar y de dónde los has sacado. Si el cambio que describo no cabe en el alcance
que he dicho, dímelo y lo acotamos antes de gastar una sesión.
