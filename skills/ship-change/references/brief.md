# Task brief — formato

Un brief por tarea, en `.superpowers/sdd/<YYYY-MM-DD-slug>/task-N-brief.md`.
El implementador (tú o un subagent) lo ejecuta **sin volver a preguntar nada**.

La regla que lo gobierna: **el brief no puede contener una decisión abierta.** Si
hay algo que el implementador tenga que interpretar, está mal puesto: o es un
dato, o es una pregunta para el usuario antes de empezar.

## Estructura

````markdown
### Task N: <título en una línea, verbo en primera persona>

**Files:**
- Create: `ruta/nueva.ts`, `ruta/test.ts`
- Modify: `ruta/existente.ts`, `ruta/otro.test.ts`
- Delete: (casi nunca; si hace falta, explica por qué)

**Interfaces:**
- Consumes: `TipoX`, `funciónY` (de Task M).
- Produces: `export type Z` (campos exactos), `export function f(a, b)`.

**Contrato:**
El comportamiento observable que debe quedar. En una frase por caso límite,
no en prosa.

**Steps:**
- [ ] 1. Escribir los tests que fallan
- [ ] 2. Implementar el helper
- [ ] 3. Extender los tipos
- [ ] 4. Implementar el módulo
- [ ] 5. Ejecutar el gate y comprobar que pasa
- [ ] 6. Actualizar `@linked` + `docs/index.md`
- [ ] 7. Commit

```bash
git add -A
git commit -m "feat(scope): qué hace, en una línea"
```

**Lo que esta tarea NO autoriza:**
- Investigar proveedores, comparar precios: sí. Contratar uno: no.
- Preparar el despliegue: sí. Publicar: no.
- Usar las credenciales de staging: sí. Crearlas o copiarlas de producción: no.
````

## Lo que la tarea no autoriza

Que exista una tarea de infraestructura no autoriza contratar un servicio. Una
tarea que menciona despliegue no autoriza publicar. Una implementación que
necesita una clave no autoriza crearla ni copiarla de ningún sitio.

La tarea puede investigar, comparar y dejar preparada una decisión **sin ejecutar
sus consecuencias**. Es la frontera entre preparar y hacer, y sin ella un
implementador competente y bienintencionado hace justo lo que no debía: escribe
el fichero de credenciales porque el paso 3 «necesita» una clave, o toca el
despliegue porque la tarea menciona el entorno.

Es de las pocas cosas que no nacen de una fuga pasada, sino de que la fuga
evite. Por eso tampoco es opcional: es barata (cuatro líneas por tarea) y es la
que impide que un agente competente se pase de listo.

## Qué poner y qué no

**El código literal cuando el diseño ya está decidido.** Si has decidido que el
tipo tiene cinco campos, escribe el tipo. El implementador no debería tener que
inventar la forma de un contrato que tú ya cerraste — ahí es donde se cuelan las
decisiones que nadie revisó.

**Los valores concretos cuando son datos.** 15 criaturas, 4 lecciones, la tabla
de rarezas. Escribe la tabla. "Añade las criaturas que falten" es una decisión
abierta y vuelve al usuario.

**Nada de comentarios tipo "implementation notes".** Si un fichero es evidente,
no lo menciones.

## Antes de dar el brief por bueno

- [ ] ¿Hay alguna palabra que admita dos lecturas? ("rápido", "simple", "fácil")
- [ ] ¿Los ficheros de `Files` son los únicos que hay que tocar? Si el
      implementador va a necesitar tocar uno más, está en la lista.
- [ ] ¿Los tests del brief describen el comportamiento, no la implementación?
- [ ] ¿Cada criterio es observable desde fuera? Sin "el código debe ser limpio".
- [ ] ¿El mensaje de commit sigue Conventional Commits y el ámbito del proyecto?
- [ ] ¿La tarea deja el repo en verde al terminar? Si no, es la mitad de otra.
- [ ] ¿Está escrito lo que NO autoriza? Y quien lo lea, ¿sabe qué no hacer sin
      tener que preguntar?

## Cuando el implementador encuentra un fallo en el brief

No lo arregla en silencio. Lo **arregla y lo escribe** en `task-N-report.md`,
en su propia sección, y lo anota en el ledger.

Es lo más valioso que produce el flujo. Un brief con seis supuestos erróneos es
información sobre tu diseño, no sobre el implementador.
