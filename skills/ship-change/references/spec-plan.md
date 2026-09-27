# Spec y plan — formato

Fases 1 y 2. Son cortas a propósito: si estás escribiendo la tercera página de un
plan, probablemente el alcance está mal.

**El spec es de la fase, el plan es de la tanda.** Un solo spec puede alimentar
varios planes —`ejemplo-f1` y `ejemplo-f2` comparten el suyo—, así que lo
que es de la fase (decisiones pendientes, aceptación humana, qué queda fuera) va
en el spec, y en el plan solo la lista ordenada de tareas. Si una decisión
pendiente acaba en el plan de una tanda, cuando releas el spec de la fase no
estará.

## Spec — `docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md`

```markdown
# <Qué cambia, en una frase>

## Problema
Qué no se puede hacer hoy, o qué está roto. Con la cita o el error real.

## Alcance
- **Sí**: lista concreta.
- **No**: lista concreta. ← la que de verdad protege el alcance

## Diseño
La solución, en prosa corta. Con las formas de datos literales.

## Casos límite
Los que no salen por el camino previsto. Uno por línea, con qué se espera.

## Decisiones pendientes
Lo que todavía no está decidido. **La sección se escribe aunque esté vacía**: si no
la pones, el hueco queda y quien lea el spec —o el agente que lo ejecute— lo
rellena como le viene, que es exactamente lo que pasa.

| Decisión | Qué bloquea | Quién decide | Antes de |
|---|---|---|---|
| ¿Dónde vive el estado de partida? | Cambia el contrato de `serialize()` | usuario | Task 3 |
| ¿Coste de la API por usuario? | Condiciona si se cachea en el cliente | usuario | Task 1 |

Una ambigüedad sin marcar la interpreta el agente a su gusto. Un hueco, peor.

## Decisiones descartadas
| Opción | Por qué no |
|---|---|
| Mantener el campo actual y migrar al vuelo | Rompe en cuanto haya dos escrituras simultáneas |
| Script de migración aparte | Un paso más que se puede saltar sin querer |

## Cómo se sabe que está terminado

### Automático
Los criterios verificables. Si aquí no hay forma de comprobarlo, el trabajo
tampoco la tiene.

### Aceptación humana
Qué tiene que ver una persona para dar la fase por buena, y que ningún test
puede decidir por ella. Se escribe al empezar la fase y se cumple al cerrarla,
**no en cada tarea**.

- Dos cuentas, dos navegadores, la partida completa
- El peso del bundle medido a mano y anotado con la cifra
- Que la lectura en voz alta no cante

Mientras no haya nada escrito aquí, el gate en verde se está tomando por el
criterio de aceptación, y no lo es.
```

Las **decisiones descartadas** son la sección que más valor da y la que más se
salta. Es lo único que evita que dentro de tres meses alguien proponga lo mismo
que ya rechazaste.

## Plan — `docs/superpowers/plans/YYYY-MM-DD-<slug>-plan.md`

El plan es la descomposición en tareas. Su trabajo es dejar cada tarea
**verificable por separado**.

```markdown
# Plan: <slug>

Spec: docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md

## Orden de tareas
| # | Qué hace | Depende de | Deja verde |
|---|---|---|---|
| 1 | Tipos + helper de sílabas | — | sí |
| 2 | Contenido (criaturas, lecciones) | 1 | sí |
| 3 | Minijuego + store | 2 | sí |
| 4 | Wiring de `PlayPage` | 3 | sí |

## Migraciones y datos
Qué se toca en base de datos, y en qué orden respecto al código. Si hay datos
existentes, el plan dice qué pasa con ellos y quién lo ejecuta.

## Orden de despliegue
Si alguna tarea no es retrocompatible con la versión desplegada, dilo aquí.
Un plan que asume que todo se despliega a la vez no es un plan, es un deseo.
```

## Las dos reglas

**Una tarea, un commit, verde al terminar.** Si al terminar una tarea el repo
está rojo, has cortado por la mitad de una tarea. Al revés también: una tarea
que no se puede revisar sola está demasiado grande.

**El plan nombra el fichero de cada tarea.** Sin `Files:` en el brief, el
implementador adivina, y adivinar es exactamente lo que produce un diff de 40
ficheros que nadie pidió.
