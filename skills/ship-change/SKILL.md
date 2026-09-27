---
name: ship-change
description: Convierte una feature en un cambio terminado mediante el flujo SDD de superpowers — spec, plan, tareas con briefs, review por tarea y ledger — y cierra con @linked, docs y tests en verde. Úsalo para features multi-archivo, refactors grandes o migraciones; para un fix pequeño, el bucle del agente developer basta.
---

# Ship a change (SDD)

El flujo que ya usas, con las partes que se estaban perdiendo afinadas. Si el
cambio cabe en un fix pequeño, **no lo conviertas en ceremonia**: usa el bucle
del agente developer y listo.

## Cuándo este flujo y cuándo no

| Cambio | Flujo |
|---|---|
| Fix de una función, texto, ajuste de estilo | Bucle del developer |
| Migración de datos, cambio de contrato, feature multi-archivo | **Este flujo** |
| Más de 3 ficheros o más de una sesión de trabajo | **Este flujo** |

## Las fases

### 0. Alcance

Antes de escribir nada, en una frase: qué cambia, qué no cambia, y cómo se
sabe que está terminado. Si no puedes decirlo, el problema no es el código, es
el alcance.

### 1. Spec

Skill `brainstorming`. Sale en `docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md`.
Es de la **fase**, no de la tanda: un solo spec puede alimentar varios planes.

Si hay decisiones que todavía no has formulado, **pregúntalas en un solo mensaje y
todas juntas**, ordenadas por lo que más bloquean. Y avanza con el valor por
defecto en las que no cambien el diseño, diciendo en el spec cuál has supuesto.

Por qué en lote, y no de una en una: cuarenta viajes de ida y vuelta antes de
escribir una línea no es rigor, es un peaje. Preguntar todo en un mensaje cuesta
lo mismo y devuelve lo mismo.

Y ojo con el motivo real: no es que el modelo decida, es que **tú veas** las
decisiones que no habías formulado. Eso pasa igual en lote que de una en una.

Si el usuario ya sabe exactamente lo que quiere, no preguntes nada: un spec corto
y a ejecutar. No le montes una elección de requisitos.

Recoge el diseño, los casos límite, **las decisiones que se descartaron y por
qué** —esa parte es la que ahorra tiempo tres semanas después— y **las que quedan
pendientes**, con qué bloquean y quién las decide. Formato en
`references/spec-plan.md`.

Una decisión pendiente no bloquea la ejecución: se anota y se sigue. Bloquea al
cerrar la tarea que dependía de ella, y eso va al ledger.

### 2. Plan

Skill `writing-plans`. Sale en `docs/superpowers/plans/YYYY-MM-DD-<slug>-plan.md`.

Descompón en tareas. Cada tarea:

- es un commit
- deja el repo en verde
- se puede revisar por separado

Una tarea que deja los tests rojos no es una tarea: es la mitad de una.

### 3. Tareas

Skill `subagent-driven-development`. Cada tarea en
`.superpowers/sdd/YYYY-MM-DD-<slug>/`:

- `task-N-brief.md` — el formato está en `references/brief.md`
- `task-N-report.md` — lo que hizo, y **qué encontró que no estaba en el brief**
- `review-<shaA>..<shaB>.diff` — el diff de la tarea

El implementador **no se limita a obedecer el brief**. Si encuentra que el brief
está mal, o que el brief y el código no encajan, lo arregla y lo deja escrito en
el report. Eso no es desviarse: es el valor del flujo.

### 4. Ledger

`progress.md` en la carpeta de la SDD. Formato y disciplina de hallazgos
diferidos en `references/ledger.md`.

### 5. Cierre

Skills `verification-before-completion` y `requesting-code-review`.

- `@linked`: cada fichero tocado actualiza su `.md` en el mismo commit, y el
  índice maestro (`docs/index.md`) crece si hay entrada nueva.
- Gate completo: tests → build → lint → e2e si toca rutas públicas o panel.
- Review final con el agente `reviewer` sobre el rango completo de la SDD.

## Las seis reglas que evitan las fugas

Cada una sale de algo que ya se te perdió en un ledger anterior. Están aquí
para que no se repitan.

### 1. Un hallazgo diferido siempre tiene destino

Encontraste algo que no es de esta tarea. **No lo escribas y sigas.**

```
important (deferred → Task 8 PlayPage wiring)
minor (rechazado: cosmético, el formateador lo arregla solo)
```

O tiene tarea, o tiene motivo del rechazo. Un `(deferred)` a secas es un
hallazgo que se pierde, y sueles encontrártelo cuando ya es otro contexto.

### 2. Los hazards se revisan al empezar una tarea, no al terminarla

Si una tarea deja un **crash latente** que se arregla tres tareas después,
mientras tanto el repo está roto para quien venga. Eso ha pasado.

Al empezar cada tarea, mira los hazards diferidos y comprueba si te tocan. Si
sí, es lo primero que arreglas. El registro de hazards está en el ledger, y se
revisa **al abrir** la tarea siguiente.

### 3. Un doc que se contradice con el `AGENTS.md` es un bug

Ha pasado: un doc afirmaba un mínimo de 64px donde el `AGENTS.md` exigía 72px.
Los tests medían lo que el doc decía, así que los dos parecían correctos y nadie
se enteró meses después.

Cuando toques un doc, contrasta sus afirmaciones con las reglas del proyecto. Si
se contradicen, el `AGENTS.md` gana y el doc se corrige.

### 4. Un test que nunca falló no es un test

Cada test nuevo se demuestra **rojo contra el código viejo** antes de pasar a
verde contra el nuevo. Si no puedes explicar cómo se rompe, el test es
decorativo y solo da falsa confianza.

### 5. Una afirmación de tamaño o rendimiento sin cifra no cuenta

No escribas "optimizado" ni "sin regresiones". Escribe los números:

```
index-*.js 380.79 kB (0 referencias) + PackScene-*.js 908.86 kB (gzip 240.81)
```

Si el cambio toca peso de bundle o rendimiento, la cifra medida va en el report.
Sin cifra, es una opinión.

### 6. Las escalaciones al dueño de la feature tienen su propio sitio

Cuando el brief y el producto se contradicen — el brief pedía algo que choca
con una regla que ya conocías —, el implementador no elige en silencio. Lo
cumple, lo cumple **por encima** de lo que le dijeron, y lo escala.

Pon esas escalaciones en una sección propia del ledger, no enterradas en el
report de una tarea. Son decisiones de producto, no de código, y se pierden con
mucho más facilidad.

## Cuándo parar y preguntar

- El spec y el código no encajan, y no hay forma obvia de resolverlo.
- Una tarea resulta ser tres.
- El gate falla y no es obvio por qué.
- El cambio toca algo que el `AGENTS.md` prohíbe explícitamente.

Parar y preguntar cuesta un mensaje. Seguir destructivamente cuesta un
`git reset` y tu confianza en el flujo.
