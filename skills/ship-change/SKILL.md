---
name: ship-change
description: Úsalo para features de varios archivos, migraciones, cambios de contrato o trabajo que abarque varias sesiones y necesite un ciclo SDD completo.
---

# Cerrar un cambio (SDD)

Flujo local para llevar un cambio sustancial desde la intención hasta commits verificados. Un fix pequeño, una función o un cambio de texto sigue el bucle normal del agente `developer`; no añadas ceremonia SDD si no hacen falta tareas coordinadas.

## Cuándo usarlo

| Cambio | Flujo |
|---|---|
| Fix pequeño, una función o texto | Bucle del developer |
| Migración, cambio de contrato o feature multiarchivo | Este flujo SDD |
| Más de tres archivos o más de una sesión | Este flujo SDD |

## Fases

### 0. Alcance

Resume en una frase qué cambia, qué no cambia y cómo se reconocerá que terminó. Si el alcance cubre subsistemas independientes, divídelo en specs antes de planificar.

### 1. Diseño y spec

Aclara propósito, usuario, restricciones, casos límite y criterios de éxito antes de implementar. Pregunta las decisiones que cambian el comportamiento; registra supuestos sólo cuando no alteren el diseño.

Escribe una spec de fase en `docs/specs/YYYY-MM-DD-<slug>-design.md`. Usa `references/spec-plan.md`. Incluye problema, alcance, diseño, casos límite, decisiones pendientes y responsables, opciones descartadas, aceptación automática y humana. Una spec de fase puede alimentar varios planes.

Si el cambio depende de elegir una interfaz de módulo o un seam de pruebas, usa `codebase-design` para comparar opciones antes de aprobar la spec.

### 2. Plan

Escribe un plan de tanda en `docs/plans/YYYY-MM-DD-<slug>-plan.md`. Descompón el trabajo en tareas ordenadas; cada tarea nombra archivos exactos, interfaces, pruebas y el cambio que deja el repo en verde. Usa `references/spec-plan.md`.

### 3. Tareas

Guarda los artefactos en `.work/sdd/YYYY-MM-DD-<slug>/`:

- `task-N-brief.md`: contrato, archivos, interfaces, pasos y acciones que la tarea no autoriza; usa `references/brief.md`.
- `task-N-report.md`: resultado, desviaciones y supuestos o defectos del brief que se descubrieron.
- `review-<shaA>..<shaB>.diff`: entrada de review para el rango de commits de la tarea.
- `progress.md`: estado, hazards, hallazgos diferidos y escalaciones; usa `references/ledger.md`.

Al empezar una tarea, lee su brief y revisa los hazards abiertos. Si uno afecta la tarea, arréglalo primero. Trabaja en ciclos red-green pequeños con `tdd`; usa `diagnosing-bugs` cuando el bug no tenga causa o reproducción fiables. Respeta el brief, conserva cambios ajenos del working tree y añade sólo las rutas nombradas, nunca `git add -A`.

Cada tarea es un commit revisable y deja el repo en verde. Tras implementarla, ejecuta sus verificaciones y pide al agente de sólo lectura `reviewer` que revise su diff. Anota el resultado y cada hallazgo diferido en el ledger antes de seguir.

### 4. Cierre

Ejecuta el gate del proyecto en el orden documentado: tests, build, lint y end-to-end si el cambio afecta rutas públicas, paneles o autenticación. Usa `verification` antes de declarar éxito y `code-review` para la review final del rango completo.

- Actualiza la documentación `@linked` y `docs/index.md` en el mismo cambio lógico cuando corresponda.
- Contrasta la documentación con el `AGENTS.md` del proyecto; una contradicción es un defecto que hay que resolver.
- Las afirmaciones sobre tamaño o rendimiento requieren cifras medidas.
- No hagas push, publiques, despliegues ni cambies cuentas externas sin autorización explícita del usuario.

## Reglas contra fugas

1. **Todo hallazgo diferido tiene destino.** Asígnale una tarea o registra por qué se rechazó; nunca lo dejes como “diferido” a secas.
2. **Revisa hazards al empezar cada tarea.** Un estado intermedio roto sigue abierto hasta que se arregle o se rechace con motivo y responsable.
3. **Un doc que contradice al `AGENTS.md` es un defecto.** Resuelve la contradicción al encontrarla.
4. **Un test que nunca falló no está demostrado.** Comprueba el red esperado antes de confiar en el verde.
5. **Las afirmaciones de tamaño o rendimiento necesitan medidas.** Registra valores antes/después cuando corresponda.
6. **Las escalaciones de producto tienen sección propia en el ledger.** No las entierres en el informe de una tarea.

## Cuándo parar y preguntar

- La spec contradice el comportamiento real y no hay un valor por defecto seguro.
- Una tarea se convierte en tareas independientes o la interfaz ya no coincide con el plan.
- Falla un gate y la causa no está clara.
- El cambio contradice una instrucción explícita del proyecto.
