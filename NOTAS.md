# Notas

Cómo funciona el arnés por dentro, y las trampas de opencode que esquiva. El
[README](README.md) es lo que necesitas para usarlo; esto es para cuando algo va
mal o para cambiar algo.

## Cómo funciona

### La config se enlaza, no se copia

Cinco rutas, todas confirmadas contra la doc de v2 y con `opencode debug paths`:

| En el repo | En `~/.config/opencode/` | Qué es |
|---|---|---|
| `opencode.jsonc` | `opencode.jsonc` | plugins, skills y MCP |
| `AGENTS.md` | `AGENTS.md` | instrucciones globales |
| `agents/` | `agents/` | agents globales |
| `skills/` | `skills/` | skills globales |
| `commands/` | `commands/` | comandos `/slash` globales |

`service.json` **no** se enlaza: lleva la contraseña del service en claro. Se
queda fuera del repo, que además lo ignora en `.gitignore`.

Ojo con `commands/`: es plural. El singular `command/` todavía se lee, pero v2
recomienda el plural para ficheros nuevos.

### Editar la config

Se edita **aquí**, no en `~/.config/opencode/`.

Y un aviso que cuesta un disgusto: `opencode plugin add` y `opencode mcp add`
reescriben el fichero entero desde el JSON parseado, así que **se llevan por
delante todos los comentarios**. Para añadir un plugin o un MCP, decláralo a
mano en `opencode.jsonc`.

Si alguna vez una de esas órdenes (o `codegraph install`) sustituye el symlink
por un fichero normal, la config deja de estar en git sin quejarse. `make check`
lo detecta y dice cómo volver.

### Plugins, MCP y skills: no son la misma cosa

Es la fuente habitual de líos, así que va explícito:

- **Plugin** — código que se ejecuta dentro de opencode. Va en el array
  `plugins`.
- **MCP** — servidores de herramientas, en `mcp.servers` (en v2 cuelgan de
  `servers`, y se desactivan con `disabled`, no con `enabled`).
- **Skill** — instrucciones en markdown que el modelo carga cuando toca. Se
  descubren por rutas conocidas, o se declaran en el array `skills`.

### Qué instala cada target

| Target | Qué hace |
|---|---|
| `make setup` | `link` + `superpowers` + `codegraph` + `compat` + `check` |
| `make superpowers` | Instala superpowers y registra sus skills |
| `make context7` | Verifica el MCP remoto de context7 (no hay nada que instalar) |
| `make context7-cli` | Instala la CLI de context7 para la terminal |
| `make codegraph` | Instala el CLI de codegraph |
| `make codegraph-snippet` | Imprime el config que codegraph escribiría, sin escribir |
| `make compat` | Symlink en la ruta antigua, para los Makefiles que no han migrado |
| `make upgrade` | Actualiza plugins, opencode y openchamber |
| `make doctor` | `check` + lo que opencode ve por su cuenta |

`check.sh` no parsea el JSON a mano: pregunta a `opencode debug config`,
`opencode mcp list` y `opencode debug agents`. Si el config estuviera mal
formado, el propio opencode lo dice. Además cuenta los agents, verifica el orden
de permisos de los que llevan shell restringida, y reinicia el service si está
desfasado o muerto.

### El `.bat` de la Desktop

Se escribe en `%USERPROFILE%\.local\bin\openchamber-desktop-wsl.bat` y **es un
único fichero compartido**: el `PROJECT_DIR` que lleva grabado es el del último
`make openchamber-desktop` ejecutado, no el de todos.

### Global es el bucle; el proyecto es el detalle

El agente global **no lleva los comandos de test hardcodeados**, y a propósito.
Un mismo proyecto puede tener `make test` *y* `npm run test:unit` y no siempre
corren lo mismo; y cada proyecto tiene su stack. Así que el agente **los
descubre**: lee el `AGENTS.md` entero, mira el `Makefile` y el `package.json`, y
dice de dónde los ha sacado antes de usarlos. Si no los encuentra, lo dice en
vez de inventarlos.

Lo específico —el tour del panel, la rama `develop`, Supabase o Firebase— se
queda en el `AGENTS.md` de cada repo, que es la fuente de verdad del proyecto.

### Las seis reglas que salían de un ledger real

El SDD ya funcionaba; lo que faltaba era que nada se perdiera en el camino. Las
seis reglas de `skills/ship-change/SKILL.md` salen cada una de algo que ya se
había escapado en un `progress.md` anterior:

1. **Un hallazgo diferido siempre tiene destino** — tarea, o motivo del rechazo.
   `(deferred)` a secas es un hallazgo que se pierde.
2. **Los hazards se revisan al abrir una tarea**, no al cerrarla. Un crash
   latente arreglado tres tareas después deja el repo roto mientras tanto.
3. **Un doc que contradice al `AGENTS.md` es un bug.** Pasó de verdad: un doc
   afirmaba 64px donde el `AGENTS.md` exigía 72px, y los tests medían lo que
   decía el doc, así que los dos parecían correctos.
4. **Un test que nunca falló no es un test** — hay que verlo rojo contra el
   código viejo antes de verlo verde.
5. **Una afirmación de tamaño o rendimiento sin cifra no cuenta** — los kilobytes
   antes y después, no la palabra «optimizado».
6. **Las escalaciones a producto tienen su propia sección** en el ledger, que es
   donde se pierden por defecto.

### Actualizaciones automáticas

Los lanzadores ejecutan `scripts/upgrade.sh` antes de arrancar, así que opencode
y openchamber se mantienen al día sin que tengas que acordarte. Se desactiva con
`SKIP_UPGRADE=1`. Las reglas, y el porqué de cada una:

- **No salta de versión mayor.** La Desktop y el server de WSL se comunican por
  un contrato (el bridge `isLocalSender`) que un cambio de major puede romper sin
  avisar. Cuando hay un major disponible, avisa e imprime el comando exacto, pero
  no lo aplica solo.
- **Nunca hace un downgrade.** En opencode esto es obligatorio: las v2 se publican
  como *prerelease*, así que el endpoint «latest release» de GitHub señala una
  v1 mientras el árbol de tags ya va por una v2. Confiar en ese endpoint
  **bajaría** el binario. Por eso se lee el tag más alto de la lista completa.
- **Solo comprueba una vez cada 24 h.** Preguntar al registry en cada arranque
  haría el launch lento y dependiente de la red.
- **Nunca impide el arranque.** Sin red, sin permiso o con el registro caído,
  avisa y sigue. `upgrade.sh` siempre sale con 0.

```sh
make upgrade                          # a mano, respeta el enfriamiento
make upgrade UPGRADE_FLAGS=--check    # solo informa, no instala
make upgrade UPGRADE_FLAGS=--force    # ignora el enfriamiento
make upgrade UPGRADE_FLAGS=--allow-major
```

> A openchamber se le habla con `npm --prefix ~/.local`, no con `npm i -g` a
> secas: un `npm i -g` mal dirigido deja **dos copias** instaladas y el symlink
> apuntando a la vieja.

## Ocho trampas

### 1. `superpowers` es un plugin de v1

Su plugin usa dos hooks de la API de v1: uno `config` que empuja su carpeta a
`config.skills.paths`, y `experimental.chat.messages.transform`. Pero en v2
`skills` es un **array plano**, así que esa escritura ya no registra nada. El
propio doc de migración avisa: *«V1 plugin implementations do not run in V2»*.

El plugin sigue declarado en `plugins` y `opencode plugin list` lo muestra
registrado (con su SHA), pero **eso no significa que sus hooks corran**: lo que
aporta son código de v1, y en v2 no tiene efecto. La vía que funciona es el
array `skills` de la config:

```jsonc
"skills": ["~/.local/share/superpowers/node_modules/superpowers/skills"]
```

Verificado: los 15 skills son visibles para el modelo, y en la lista salen
`test-driven-development`, `verification-before-completion`, `writing-plans`,
`brainstorming` y `subagent-driven-development`, que son los que usa el agente
`developer` y la skill `ship-change`.

Ojo también: el paquete `superpowers` de npm es **otro** (0.0.2), no este. La
fuente buena es la de git.

### 2. `codegraph install` no entendería la config ni aguantaría el symlink

Dos motivos, y el segundo es el que duele:

1. Escribe en `~/.config/opencode/opencode.jsonc`. Como esa ruta es un symlink
   a este repo, podría sustituir el enlace por un fichero normal y dejar la
   config fuera de git sin avisar.
2. **Su propio snippet sigue en formato v1.** `make codegraph-snippet` lo
   enseña: cuelga de `mcp` en vez de `mcp.servers`, y usa `enabled: true` en vez
   de `disabled`.

Por eso el bloque de codegraph en `mcp.servers` está **copiado a mano** en forma
v2, y el target instala solo el CLI.

### 3. Las listas de opencode no leen el disco, y `reload` no siempre basta

`opencode mcp list`, `opencode plugin list` y `opencode debug agents` no leen los
ficheros: preguntan al **service en background**. Ese service guarda un snapshot
de la config, así que hay dos fallos distintos que se confunden:

- **Service desfasado** — está vivo pero con la config de antes. Responde «No MCP
  servers configured» y un catálogo de agents con solo los de fábrica. Lo arregla
  `opencode reload`.
- **Service muerto** — no está. La CLI devuelve el catálogo **vacío**, y `reload`
  no lo resucita. Hay que matarlo (`pkill -f 'opencode serve --service'`) para
  que la CLI lo levante ya con la config buena.

Y un tercero: el service se levanta **por demanda** y tarda un par de segundos en
cargar la config global. Si le preguntas nada más arrancar, devuelve el catálogo
vacío y diagnosticas como «desfasado» algo que solo tiene prisa. Por eso
`check.sh` espera antes de sondear, y distingue los dos casos.

No es teoría: sin service, `make check` daba por buenos `plugin list` sin
plugins, `mcp list` sin servidores y `debug agents` con solo los de fábrica,
cuando el disco tenía los 15 skills, los 2 MCP y los 3 agents globales. Los tres
eran falsos negativos del mismo sitio.

### 4. `opencode serve` está autenticado y no tiene `/health`

Al revés que `openchamber serve`. Este imprime una contraseña y su `/api/*` es
`401` sin ella; aquel responde `200` en `/health` sin pedir nada. La consecuencia
práctica: **el mismo `curl /health` que sirve para OpenChamber no prueba nada
aquí**, porque `/health` devuelve el HTML de la SPA. La comprobación real de que
el servidor de opencode está bien es que su log imprima la contraseña, que es lo
que hace `scripts/opencode-serve.sh`.

Para conectar un navegador o una app sin contraseña está `opencode pair`, que
imprime enlaces de un solo uso válidos cinco minutos. Ese enlace va contra el
**service de fondo**, no contra un proyecto concreto, así que no encaja con
`PROJECT=`.

### 5. El `directory` de una sesión puede venir corrupto

`opencode session list --format json` da el `directory` donde se creó cada
sesión, que es lo que permite atribuirlas a un worktree. Pero no siempre es una
ruta POSIX limpia: hay sesiones creadas desde el opencode de **Windows** contra
una ruta de WSL, guardadas con el prefijo UNC pegado al final.

```
/home/ubuntu/proyecto/\\wsl.localhost\Ubuntu\home\ubuntu\proyectos\proyecto
```

Por eso el janitor compara con `realpath` y con igualdad de ruta, y nunca
buscando si una ruta contiene a la otra como texto: eso casa donde no debe y
borra sesiones de otro sitio.

Aparte: las sesiones de la instalación de Windows son **otro almacén**, con
otros ids. Desde WSL no se ven y no hay forma de borrarlas desde aquí.

### 6. No parsees el JSON de opencode con `grep`

Y esto no es una opinión, es la tercera vez que lo rompe el mismo fichero.

`opencode debug agents` devuelve JSON con acentos, comillas y arrays. `check.sh`
lo llevaba con `sed` y `grep`, y falló tres veces seguidas:

1. `tr -d ' '` para aplanar el JSON **borraba el espacio** de `"git *"`. El
   patrón jamás casaba y el diagnóstico salía como «sin excepción git».
2. Medir la posición del deny y del allow sobre el JSON entero comparaba **el
   deny de un agente con el allow del siguiente** en cuanto había más de uno.
3. `grep -bo` cuenta **bytes** y `cut -c` cuenta **caracteres**. Con acentos, los
   dos offsets no son comparables y el recorte sale mal.

Las tres son el mismo error de fondo. Los permisos se comprueban ahora en
`scripts/check-perms.py`, que usa `json.loads` e indexa la lista. La regla
general: si hay un `json` disponible, no lo parsees con `grep`.

Y un cuarto, del mismo barrio: en bash, **un acento grave sin escapar dentro de
comillas dobles es sustitución de comandos**. Si un mensaje lleva el nombre de
una orden entre acentos graves y no los escapas, bash ejecuta esa orden en
cuanto lee la línea. En este repo todos los mensajes llevan el acento grave
precedido de barra, y basta uno sin escapar para que salga `edit: command not
found` en mitad de un diagnóstico.

### 7. El PATH no interactivo de WSL

Una shell no interactiva no trae `~/.local/bin`. Por eso el `Makefile` fija el
PATH y usa `npm --prefix ~/.local i -g`: el `npm` del PATH viene de otra
instalación y sus globales se irían a `/usr/local`, duplicando binarios.

Y lo mismo rompe el `.bat` de OpenChamber, que arranca el server con
`wsl.exe -e bash -lc` y por tanto sin `~/.bashrc`. Sin `OPENCODE_BINARY` explícito
muere con `Unable to locate the opencode CLI on PATH`. No lo quites.

### 8. En los permisos, gana la última regla que coincide

Este es el fallo silencioso que casi se cuela, y por eso `check-perms.py` lo
comprueba. En `agents/reviewer.md` queremos permitir `git` y denegar el resto de
`shell`. Escrito en el orden intuitivo —primero la excepción, después la regla
amplia— no funciona:

```yaml
- action: shell
  resource: "git *"
  effect: allow
- action: shell
  resource: "*"
  effect: deny      # esta gana, y se come el allow de arriba
```

Gana la **última** regla que coincide, así que la regla amplia va **antes**:

```yaml
- action: shell
  resource: "*"
  effect: deny
- action: shell
  resource: "git *"
  effect: allow     # esta gana, y es la excepción que queríamos
```

El síntoma es desconcertante: el reviewer existe, responde con soltura, y no
puede ni ejecutar `git diff`. No da ningún error; simplemente nunca ve el cambio.
Con `read` pasa lo mismo al revés: añadir un `read allow *` al final anularía la
protección que opencode pone sobre los `.env`, y por eso el reviewer no toca los
permisos de lectura.
