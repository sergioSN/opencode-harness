# Hacer propio el flujo SDD

## Problema

El arnés depende de Superpowers para instalar y descubrir skills de ingeniería, aunque `skills/ship-change` ya contiene reglas propias. El flujo también acopla los artefactos a nombres del proveedor: specs y planes van bajo `docs/superpowers/`, y briefs, informes y ledger bajo `.superpowers/sdd/`. Al retirar Superpowers sin reemplazar esas capacidades, el agente perdería pasos del flujo y referencias de skills.

## Objetivo

Eliminar la dependencia operativa de Superpowers y mantener un SDD completo, propio y versionado. Conservar las fases y reglas útiles que el repo ya define; reutilizar sólo prácticas seleccionadas de Matt Pocock como base editable, adaptándolas al flujo local.

## Alcance

- **Sí:** mantener `/ship` y `skills/ship-change` como entrada y orquestador del SDD.
- **Sí:** mantener scope/diseño, spec, plan, tareas pequeñas, pruebas, review, informes y ledger.
- **Sí:** conservar las reglas existentes contra hallazgos diferidos sin destino, hazards, contradicciones con `AGENTS.md`, tests que no fallaron primero, afirmaciones sin evidencia y escalaciones de producto perdidas.
- **Sí:** retirar la instalación/configuración de Superpowers y sustituir sus referencias por skills locales.
- **Sí:** usar como material de partida, adaptado y no como dependencia de ejecución, prácticas de TDD, diagnóstico de bugs, code review y diseño de arquitectura de Matt Pocock.
- **Sí:** documentar Impeccable y el catálogo de Matt Pocock como complementos opcionales para usuarios que ya los tengan o quieran consultarlos; Impeccable se recomienda para trabajo de UI y el material de Matt complementa el catálogo local.
- **No:** hacer que las skills externas sean requisitos de `make setup`, `make check` o `/ship`; el flujo SDD debe seguir funcionando con las skills versionadas aquí.
- **Sí:** tratar el `skills/tdd/` local sin seguimiento como material de partida para TDD; revisar y adaptar su contenido, no sobrescribirlo a ciegas.
- **No:** importar el catálogo completo de Matt Pocock ni su setup de issue tracker, `to-spec` o `implement-spec` sin adaptación.
- **No:** borrar automáticamente una instalación existente en `~/.local/share/superpowers`.
- **No:** modificar ni incluir otras skills preexistentes sin seguimiento; sólo se adaptará el subconjunto seleccionado explícitamente.
- **No:** modificar los plugins MCP, OpenChamber u otros componentes no relacionados.

## Diseño

### Flujo local

`/ship` seguirá delegando al agente `developer`. Para cambios grandes, `skills/ship-change` coordinará todo el ciclo y sus referencias locales:

1. Aclarar propósito, alcance, casos límite y aceptación humana.
2. Escribir una spec de fase y un plan de tanda.
3. Ejecutar tareas revisables; cada tarea tiene brief, resultado, review y verificación.
4. Mantener un ledger con estado, hazards, hallazgos diferidos y escalaciones.
5. Cerrar con el gate del proyecto y una review final.

La práctica de diseño/spec y la coordinación de tareas serán propias de `ship-change` o de referencias locales. Las skills auxiliares locales cubrirán TDD, diagnóstico, verificación, code review y diseño de arquitectura. El contenido actual de `skills/tdd/` es una semilla para esa adaptación, no un contrato que se copie sin revisión. No se conservarán invocaciones a IDs que sólo existan en el paquete Superpowers.

### Ubicación de artefactos

- Specs: `docs/specs/YYYY-MM-DD-<slug>-design.md`.
- Planes: `docs/plans/YYYY-MM-DD-<slug>-plan.md`.
- Briefs, informes, diffs de review y ledger: `.work/sdd/YYYY-MM-DD-<slug>/`.

Los artefactos SDD de `.work/sdd/` seguirán versionados; no se añadirán a `.gitignore`. En el estado actual no hay artefactos existentes en las rutas `docs/superpowers/` o `.superpowers/sdd/`, así que no se requiere migrar contenido.

### Configuración e instalación

- Quitar de `opencode.jsonc` sólo el plugin Superpowers y su ruta explícita de skills; conservar el plugin de OpenChamber.
- Quitar del `Makefile` variables, target, ayuda y dependencia de `setup` que instalan Superpowers.
- Reemplazar en `scripts/check.sh` las comprobaciones del paquete externo por comprobaciones de los skills locales requeridos.
- Actualizar `AGENTS.md`, `agents/developer.md`, `commands/ship.md`, `skills/.gitkeep`, `README.md` y `NOTAS.md` para describir el flujo local sin instrucciones obsoletas.
- Confirmar durante la implementación, contra OpenCode V2, que la carpeta `skills/` enlazada a `~/.config/opencode/skills` descubre los skills locales sin el array externo.

La eliminación sólo afecta a la dependencia del repo: no ejecutará desinstalaciones ni borrará archivos en el home del usuario.

## Criterios de aceptación

1. `make setup` y `make check` no requieren descargar, encontrar ni invocar Superpowers.
2. OpenCode descubre los skills locales necesarios desde el directorio versionado del repo.
3. `/ship` y `developer` pueden completar el ciclo SDD sin IDs de skills externos.
4. Las fases, las seis reglas de prevención de fugas y las salvaguardas de commit/review siguen presentes.
5. Specs y planes nuevos usan `docs/specs/` y `docs/plans/`; el estado de tareas usa `.work/sdd/`.
6. La documentación y ejemplos no enseñan rutas ni comandos operativos obsoletos de Superpowers.
7. La instalación local preexistente y los skills sin seguimiento quedan intactos.
8. README y notas distinguen skills propias requeridas de catálogos externos opcionales, con enlaces y alcance; ninguna verificación o setup depende de estos catálogos.

## Verificación prevista

- Pruebas estáticas que detecten referencias operativas restantes a Superpowers y skill IDs externos.
- `make -n setup` y `make check` para verificar el setup y el diagnóstico sin instalación externa.
- Validación con OpenCode V2 del catálogo efectivo de skills y del agente `developer`.
- Prueba del flujo SDD con una tarea pequeña: spec, plan, brief, ledger, test red/green y review.

## Decisiones descartadas

| Opción | Motivo |
|---|---|
| Mantener Superpowers y sólo renombrar `docs/superpowers/` | Deja la dependencia y los IDs externos intactos. |
| Copiar todo el catálogo de Superpowers o Matt Pocock | Mantiene más contenido y mantenimiento del necesario para este arnés. |
| Adoptar el `implement-spec` y el setup de tracker de Matt sin cambios | No son equivalentes al SDD local ni a sus rutas y ledger. |

## Decisiones pendientes

Ninguna para esta fase. Los detalles de los nombres de los skills locales y sus contratos se cerrarán en el plan de implementación, manteniendo los límites de este diseño.
