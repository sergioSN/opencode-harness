# Instrucciones globales

Este fichero está enlazado en `~/.config/opencode/AGENTS.md`, así que OpenCode
lo carga en **todos** proyectos, antes que los `AGENTS.md` de cada repo.

Contiene el flujo de trabajo global y hechos verificados de esta máquina. Tus
preferencias personales (estilo de commits, cómo preguntar, qué no tocar)
irían aquí abajo: esta parte global no puede competir con el `AGENTS.md` de un
repo, que siempre se carga después.

## Hay un flujo de trabajo global: úsalo en vez de improvisar

En `~/.config/opencode/` hay cuatro piezas que se cargan en **todos** los
proyectos:

| Qué | Para qué |
|---|---|
| Agente `developer` | Lleva un cambio de principio a fin: test antes que código, `@linked` sincronizado, docs y gate en verde |
| Agente `reviewer` | Revisa un diff en busca de bugs, tests que faltan y docs desincronizadas. Solo lectura: `edit` denegado y `shell` limitado a `git` |
| Skill `ship-change` | El SDD completo (spec → plan → tareas con briefs → review → ledger) para cambios grandes |
| Comando `/ship` | Arranca el bucle con el estado de git ya en el prompt |

No los reimplementes ni los describas de memoria: están versionados aquí, y este
repo es la configuración global de opencode.

**El `AGENTS.md` de cada proyecto manda sobre ellos** para todo lo específico de
ese repo: los comandos de test reales, las reglas de negocio, qué no tocar. El
agente global define el bucle, no los comandos de tu proyecto.

### Las listas de opencode van por el service, no por el disco

`opencode debug agents`, `opencode mcp list` y `opencode plugin list` **no leen
los ficheros**: preguntan al service en background, que guarda un snapshot de la
config. Por eso pueden mentir aunque el disco esté bien.

Tres casos distintos, y confundirlos cuesta mucho rato:

| Síntoma | Causa | Arreglo |
|---|---|---|
| Catálogo con los 4+3 de fábrica, `mcp list` dice que no hay servidores | Service desfasado | `opencode reload` |
| Catálogo **vacío**, y `reload` no lo arregla | Service muerto | `pkill -f 'opencode serve --service'` y deja que la CLI lo levante |
| Catálogo vacío justo después de arrancar | El service tarda unos segundos en cargar | Espera antes de preguntar |

Ese último es el que más engaña: el service se levanta por demanda, así que la
primera consulta le llega mientras todavía carga y parece un fallo de config que
no existe.

**Consecuencia práctica: antes de concluir que algo no está configurado,
comprueba si el service lo está diciendo.** Un `plugin list` que sale vacío, un
`mcp list` sin servidores o un `debug agents` con 7 son todos el mismo síntoma.

### `~/.agents/skills/` también es un sitio global

Además de `~/.config/opencode/`, opencode lee `~/.agents/skills/`, y ahí tienes
skills globales (`firebase-*`, `tailwind-css-patterns`, `supabase-*`,
`frontend-design`, `typescript-advanced-types`…). El log avisa con
`duplicate skill name` cuando un proyecto trae el mismo skill en
`.agents/skills/`: no es un error, pero el que gana es el global.

## Entorno

### El shell de fuera es PowerShell, y rompe cosas

El terminal de este harness es PowerShell, no bash. Al ejecutar comandos de
WSL **usa siempre**:

```sh
wsl -d Ubuntu --exec <comando> <args sin comillas>
```

Lo que PowerShell manipula por su cuenta y llega corrupto a WSL:

- comillas dobles y simples anidadas
- `$` (expande variables de PowerShell)
- `(`, `)`, `?`, `!`, `;`, `&`
- redirecciones y pipes

No uses `<<<` (here-strings de bash): no existen ahí. Cuando un comando tenga
comillas o caracteres raros, **escribe el script a un fichero y ejecútalo**;
eso funciona siempre:

```sh
# en vez de pelearte con el escapado
wsl -d Ubuntu --exec bash /ruta/al/script.sh
```

Dentro de esos scripts sí puedes usar bash normal: here-docs, `$(...)`,
comillas, pipes.

### El PATH no interactivo está incompleto

Una shell no interactiva de WSL **no** trae `~/.local/bin` ni
`~/.opencode/bin`. Esto ya rompió el launcher de openchamber una vez y
escondió `gh` durante meses. En scripts y Makefiles, fija el PATH:

```sh
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
```

### `npm` global sin `--prefix` instala donde no toca

El `npm` del PATH es el de Hermes, y sus instalaciones globales van a
`/usr/local`, lo que duplica binarios. Usa siempre:

```sh
npm --prefix ~/.local i -g <paquete>
```

### Ficheros que no existen o no hacen lo que parecen

- `/usr/bin/timeout` es un **symlink roto**. No lo uses.
- `openchamber logs` es un `tail -f` y bloquea. Para mirar:
  `tail -n 30 /tmp/openchamber-serve.log`
- `~/.local/bin/openchamber-desktop` apunta a un directorio que ya no existe.

### La versión de opencode no tiene una fuente única, a propósito

- local: `v2.0.18`
- `npm view opencode-ai`: `1.18.32`
- `gh api repos/sst/opencode/releases/latest`: `v1.18.32`
- pero la lista de tags llega a `v2.0.18`

La causa: **v2 se publica como prerelease**, así que "latest release" de GitHub
se queda atrás. **Nunca decidas una actualización con "latest release"**: mira
los tags, o usa el mecanismo de `scripts/upgrade.sh` del repo `_openchamber`,
que bloquea los saltos de versión mayor sin `--allow-major`.

### opencode está duplicado entre WSL y Windows

Está en `%USERPROFILE%\.opencode\bin\opencode.exe`, con **config aparte**.
Actualizar el de WSL no toca el de Windows, y viceversa. Además,
`opencode debug config` muestra un origen de configuración en
`/mnt/c/Users/<usuario>/.opencode` que se escanea desde WSL: si algo parece
aparecer dos veces, mira ahí primero.

### Editar `.bat` sin romper los finales de línea

Los `.bat` de los launchers están en CRLF. La herramienta de edición normal
estrofa el salto de línea y ensucia el fichero entero de diffs. Parchéalos con
un script de perl y commitea solo el diff real.

### `make` es el único verificador fiable de tabuladores

Si una receta del Makefile lleva espacios en vez de tabulador, `make -n` falla
con "missing separator". No lo deduzcas del aspecto del fichero: ejecútalo.

### Los mensajes de commit, a fichero

`git commit -m "..."` con PowerShell expande `$HOME` dentro de las comillas y
te commitea una ruta nueva. Escribe el mensaje a un fichero temporal y usa
`git commit -F <fichero>`.
