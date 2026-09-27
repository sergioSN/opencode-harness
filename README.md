# opencode-harness

La configuración global de **opencode**, puesta en git, y los lanzadores para
trabajar con ella desde la terminal, el navegador y OpenChamber.

opencode lee sus ajustes de `~/.config/opencode/`, que es una caja negra: sin
git, sin diff, sin forma de saber qué cambió ni cuándo. Aquí esa caja está
abierta. Y no se copia nada: se **enlaza**, así que un cambio se ve al instante
y no hay dos versiones que se desincronicen.

## Qué contiene

| Qué | Para qué |
|---|---|
| `opencode.jsonc` | plugins, skills y servidores MCP |
| `AGENTS.md` | instrucciones globales |
| `agents/` | tres agentes: `developer`, `reviewer`, `janitor` |
| `skills/ship-change/` | el flujo spec → plan → tareas → review → ledger |
| `commands/ship.md` | `/ship <feature>` |
| `Makefile` | los lanzadores y el resto de targets |
| `scripts/` | enlazar, comprobar, lanzar y actualizar |

## Instalar

```sh
git clone https://github.com/sergioSN/opencode-harness.git
cd opencode-harness
make setup    # enlaza la config, instala plugins y CLIs, y comprueba
make check    # el estado real, preguntando al propio opencode
```

Hace falta WSL, Linux o macOS; el binario de opencode **v2** en el `PATH`; y
`make`, `git` y `node`.

Los lanzadores de OpenChamber necesitan además su UI web
(`npm --prefix ~/.local i -g @openchamber/web`) y la Desktop instalada **en
Windows**. Sin nada de eso, la config y los agentes siguen funcionando.

> **Dónde lo clones importa.** Los Makefiles de tus proyectos apuntan a este repo
> por ruta, así que si no está donde esperan, fallan con un error que no se
> entiende solo. Si vienes del repo anterior, `make setup` deja un symlink en la
> ruta antigua y tus Makefiles siguen funcionando sin tocarlos.

## Usarlo

```sh
make opencode            PROJECT=...   # el TUI
make opencode-web        PROJECT=...   # la web de opencode, en el 4096
make openchamber-desktop PROJECT=...   # ventana nativa
make openchamber-web     PROJECT=...   # la UI de OpenChamber, en el 3001
make stop                               # para los dos servidores
make status                             # qué hay en marcha
```

Los seis necesitan `PROJECT=`: «el directorio actual» sería este repo, que no es
un proyecto de opencode, así que no se adivina. También funcionan desde el
Makefile de cada proyecto, si los tiene. `desktop` y `web` son alias de los dos
de OpenChamber.

**`opencode-web` te imprime una contraseña.** `opencode serve` arranca
autenticado y su API responde `401` sin ella, así que el target la captura del
log y te la enseña. Sin eso tendrías una web en blanco sin explicación.

## Los agentes

| Agente | Qué hace |
|---|---|
| `developer` | Lleva un cambio de principio a fin: test antes que código, docs sincronizadas, verde al terminar. |
| `reviewer` | Revisa un diff: bugs, tests que faltan, commits no atómicos, afirmaciones sin cifras detrás. **Solo lectura.** |
| `janitor` | Limpia lo que deja una rama mergeada: worktree, rama local, rama remota y sesiones. **Borra**, así que primero informa. |

El flujo global define el método, no los comandos de tu proyecto: cada agente
descubre los tests leyendo tu `AGENTS.md` y tu `Makefile`, y dice de dónde los
ha sacado. Lo específico se queda en el `AGENTS.md` de cada repo, que es la
fuente de verdad del proyecto.

## Si algo falla

| Síntoma | Causa |
|---|---|
| La web de opencode carga y no muestra nada | Falta la contraseña; mira lo que imprimió el target. |
| `openchamber: not found` | Target de Make ejecutado sin `PATH` explícito. |
| `Unable to locate the opencode CLI` | Falta `OPENCODE_BINARY` en el `.bat` de la Desktop. |
| La Desktop de OpenChamber abre sin sesiones | No está conectada al server de WSL: se abrió con su propio server de Windows. |
| `[ipc] rejected ... from non-local origin` | Se cargó la UI remota en vez de la empaquetada. |
| Las dos mitades van de versiones distintas | Se actualizó una y no la otra: `make upgrade UPGRADE_FLAGS=--allow-major`. |

```sh
make check   # pregunta a opencode qué ve, y dice qué está mal
```

Logs:

```sh
wsl -d Ubuntu -e tail -n 30 /tmp/openchamber-serve.log
wsl -d Ubuntu -e tail -n 30 /tmp/opencode-serve/4096.log
```

## Notas

Ocho trampas de opencode que este repo esquiva, con el porqué de cada una, en
[NOTAS.md](NOTAS.md). La que más cuesta: `opencode debug agents` y compañía no
leen el disco, preguntan al service en background, así que pueden mentir aunque
todo esté bien en el fichero.

## Licencia

MIT. Ver [LICENSE](LICENSE).
