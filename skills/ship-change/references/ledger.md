# Ledger (`progress.md`) — formato y disciplina

`progress.md`, en `.superpowers/sdd/<YYYY-MM-DD-slug>/`. Es el estado del
proyecto para quien llegue en frío: dentro de seis meses, tú.

No es un diario. Es la respuesta a tres preguntas: **qué está hecho, qué se
aplazó, y qué está roto a medias.**

## Estructura

````markdown
# SDD ledger — plan: docs/superpowers/plans/2026-10-05-ejemplo-f2.md

## Task status

Task 1: complete (commits aaaaaaa..bbbbbbb, review clean)
- El implementador encontró 6 supuestos erróneos en el brief; todos corregidos.
- Ronda de fix: creó `docs/informes/resumen.md` + `docs/lib/fechas.ts`;
  actualizó `docs/informes/diario.md` desfasado y `docs/index.md`; restauró la
  precondición de rango en `esValida()`.
- minor (rechazado: cosmético, el formateador lo normaliza) — falta newline
  final en `docs/lib/tipos.md`.

Task 2: complete (commits bbbbbbb..ccccccc, review clean)
- Ronda de fix: filtro real del pool + tests de `elegirPorFrecuencia()` con
  `rangosCompletados`, tope 2⭐/0⭐, registros `mixtos`.

## Hazards abiertos

- **none**

## Escalaciones

- none

## Cierre

- Gate: `npm test` 187 ✓ · `npm run build` ✓ · `npm run lint` 0 ✓ · e2e 9 ✓
- `@linked`: 3 docs creados, 4 actualizados, `docs/index.md` +7 filas
- Bundle: `index-*.js` 241.06 kB + `Panel-*.js` 612.33 kB (gzip 168.90)
````

## Las tres secciones del ledger

Las dos últimas son las que evitan las fugas: sin ellas, lo que se descubre a
media tarea se pierde.

### Task status

Cada tarea termina en un estado con su rango de commits y el veredicto del
review. Los bullets de debajo son lo que **no** se ve en el diff: supuestos
erróneos del brief, docs que había que crear y detalles que hubo que corregir.

Si el implementador no encontró nada que corregir, eso también se escribe.
`Implementer found 6 issues in brief` es una línea que vale oro; su ausencia
sobre un brief de 250 líneas significa que no lo leyó con cuidado.

### Hazards abiertos

Un hazard es **un estado intermedio que está roto**: un crash latente, una
contradicción entre dos módulos, un test que se saltó a propósito para llegar al
final de la tarea.

Vive aquí **hasta que se cierra**, y se mira **al abrir cada tarea siguiente**, no
al cerrarla. La diferencia es entre llegar a la tarea 8 sabiendo que el crash
sigue ahí y arreglarlo a propósito, o tropezarse con él de rebote tres tareas
después.

- **none** es una respuesta válida y la correcta la mayoría de las veces.
- Un hazard con dueño: `- **[H1]** createSilabaInicialExercise crashea con
  lesson.words vacío (vocales) → Task 8, guard en el constructor. Dueño:
  implementador de Task 8.`
- Un hazard sin dueño **no puede quedar escrito**. O le pones tarea, o lo
  arreglas ahora, o lo rechazas por escrito.

### Escalaciones

Decisiones de producto, no de código. Cuando el brief pide algo que choca con una
regla que ya conocías, o con el criterio del proyecto, el implementador lo cumple,
lo cumple por encima, y lo escala. Eso se anota aquí y en ningún otro sitio.

## Hallazgos diferidos: la regla dura

Encontraste algo que no es de esta tarea. Tienes dos salidas y **ninguna** es
dejarlo suelto:

```
important (diferido → Task 8, wiring de PlayPage)
minor (rechazado: rama muerta, el linter ya la marca y no molesta)
```

Nada de `(diferido)` a secas. Un hallazgo sin destino sobrevive hasta que el
proyecto crece, y entonces lo encuentras cuando ya es otro contexto y otro
autor. La clasificación:

| Gravedad | Qué es | Efecto |
|---|---|---|
| `blocking` | Bug o regresión | Se arregla antes de cerrar la tarea |
| `important` | Falta un test, doc desincronizada, afirmación sin evidencia | **Tarea obligatoria con número** |
| `minor` | Limpieza, nombres, cosmético | Se arregla o se rechaza por escrito |

## Al cerrar cada tarea

- [ ] Rango de commits anotado
- [ ] Veredicto del review anotado
- [ ] Supuestos erróneos del brief, en sus propias palabras
- [ ] **Todo diferido con destino o con motivo de rechazo**
- [ ] Hazards: los nuevos escritos, los viejos cerrados
- [ ] Tests nuevos demostrados rojos contra el código viejo (no basta con
      verlos verdes)
- [ ] Si toca peso de bundle o rendimiento: la **cifra medida**, no el adjetivo
