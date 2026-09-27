# ============================================================
#  opencode-harness — el arnés de opencode, y OpenChamber encima
# ------------------------------------------------------------
#  make setup        instala todo: enlaces, plugins, CLIs
#  make check        estado real de todo el stack
#  make opencode / opencode-web / openchamber-*   lanzadores
#
#  Los lanzadores necesitan PROJECT=: aquí "el directorio actual"
#  sería este repo, que no es un proyecto de opencode.
# ============================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

REPO        := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
OC_DIR      ?= $(HOME)/.config/opencode
NPM_PREFIX  ?= $(HOME)/.local
SP_PREFIX   ?= $(HOME)/.local/share/superpowers
SP_REPO     := https://github.com/obra/superpowers.git
SP_PKG      ?= superpowers@git+$(SP_REPO)

# `npm` a secas es el de Hermes y sus globales se van a /usr/local, que es
# justo el duplicado que hubo que arreglar con openchamber. Con --prefix la
# instalación cae en ~/.local, que ya está en el PATH.
NPM := npm --prefix $(NPM_PREFIX)

# El PATH no interactivo de WSL no trae ~/.local/bin; sin esto, make no ve ni
# gh ni los binarios que instala este repo.
export PATH := $(HOME)/.opencode/bin:$(NPM_PREFIX)/bin:/usr/local/bin:/usr/bin:/bin

# Proyecto al que apuntan los lanzadores. Obligatorio en todos ellos.
PROJECT ?=

# Puertos: OpenChamber ya usaba el 3001, así que opencode serve va al 4096.
# Chocarlos daría un error de EADDRINUSE que no dice de quién es el puerto.
OPENCHAMBER_PORT ?= 3001
OPENCODE_PORT    ?= 4096

# El upgrade automático se puede desactivar con SKIP_UPGRADE=1.
UPGRADE_SH = bash "$(REPO)/scripts/upgrade.sh"

ifneq ($(SKIP_UPGRADE),1)
DO_UPGRADE = @$(UPGRADE_SH)
else
DO_UPGRADE = @:
endif

# Guarda común de los cuatro lanzadores. $@ es el target que la invoca.
CHECK_PROJECT = @test -n "$(PROJECT)" || { \
	echo "❌ Falta PROJECT. Uso: make $@ PROJECT=/ruta/al/proyecto"; \
	exit 1; \
}; \
	test -d "$(PROJECT)" || { \
	echo "❌ El proyecto no existe: $(PROJECT)"; \
	exit 1; \
}

.PHONY: help link unlink check setup doctor compat \
        superpowers context7 context7-cli codegraph codegraph-snippet \
        opencode opencode-web \
        openchamber-desktop openchamber-web desktop web \
        stop status upgrade clean

## ------------------------------------------------------------- ayuda
help: ## Muestra esta ayuda
	@echo ""
	@echo "  opencode-harness — configuración global de opencode + lanzadores"
	@echo "  repo: $(REPO)"
	@echo "  dest: $(OC_DIR)"
	@echo ""
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  make setup   = link + compat + superpowers + codegraph + check"
	@echo ""
	@echo "  PROJECT= es obligatorio en los seis lanzadores."
	@echo "  Ej:  make opencode-web PROJECT=~/projects/mi-proyecto"
	@echo ""
	@echo "  SKIP_UPGRADE=1 desactiva el chequeo de actualizaciones."
	@echo ""

## ---------------------------------------------------------- enlaces
link: ## Enlaza opencode.jsonc, AGENTS.md, agents/, skills/ y commands/
	@bash $(REPO)/scripts/link.sh

unlink: ## Quita los enlaces (solo los que apunten a este repo)
	@bash $(REPO)/scripts/link.sh --unlink

check: ## Estado real de todo, verificado con el propio opencode
	@bash $(REPO)/scripts/check.sh

# Los Makefiles de los proyectos apuntaban al repo viejo por ruta:
#   OPENCHAMBER_COMMON ?= $(HOME)/projects/_openchamber
#   OPENCHAMBER_LAUNCHER = $(OPENCHAMBER_COMMON)/scripts/openchamber-desktop-wsl.sh
# Es lo UNICO que necesitan de aqui, asi que un symlink en la ruta vieja los
# deja funcionando sin editar un solo Makefile. Es un parche: lo definitivo es
# cambiar OPENCHAMBER_COMMON en cada proyecto.
compat: ## Symlink en la ruta vieja, para los Makefiles que aun no han migrado
	@old=$(HOME)/projects/_openchamber; \
	if [ -e "$$old" ] && [ ! -L "$$old" ]; then \
		echo "  $$old existe y no es un symlink."; \
		echo "  probably es el repo viejo clonado. Muevelo o borralo antes."; \
		exit 1; \
	fi; \
	if [ -L "$$old" ]; then \
		echo "  ya apunta a $$(readlink $$old)"; \
	elif [ -e "$$old" ]; then \
		echo "  ya existe"; \
	else \
		ln -s "$(REPO)" "$$old" && echo "  $$old -> $(REPO)"; \
	fi
	@echo ""
	@echo "  Tus proyectos con OPENCHAMBER_COMMON siguen funcionando."
	@echo "  Para dejarlo bien: cambia esa variable por $(REPO)"
	@echo "  y luego borra este symlink."

## ------------------------------------------------------------ plugins
superpowers: ## Instala superpowers y deja sus skills en el array `skills`
	@echo "==> superpowers"
	@echo "    OJO: el paquete \`superpowers\` de npm es otro (0.0.2), no este."
	@echo "         La fuente real es el repo de git."
	@mkdir -p $(SP_PREFIX)
	@npm --prefix $(SP_PREFIX) i --no-fund --no-audit "$(SP_PKG)"
	@echo ""
	@echo "    instalado en: $(SP_PREFIX)/node_modules/superpowers"
	@echo "    skills:"
	@find $(SP_PREFIX)/node_modules/superpowers/skills -name SKILL.md 2>/dev/null \
	  | sed 's|.*/skills/||;s|/SKILL.md||' | sort | tr '\n' ' ' | fold -s -w 62 | sed 's/^/      /'
	@echo ""
	@echo "    Ya está en el array \`skills\` de opencode.jsonc. Comprueba con:"
	@echo "      make check"
	@echo ""
	@echo "    El plugin de V1 (hooks config + experimental.chat.messages.transform)"
	@echo "    probablemente no corre en V2; por eso los skills se registran"
	@echo "    apuntando a la ruta de arriba y no confiando en el hook."

context7: ## Context7: MCP remoto, no hay nada que instalar. Opcional: la CLI
	@echo "==> context7"
	@echo "    El MCP es remoto (https://mcp.context7.com/mcp) y ya está"
	@echo "    declarado en mcp.servers.context7. No requiere instalación:"
	@echo "    opencode se encarga del OAuth."
	@echo ""
	@echo "    Estado:"
	@opencode mcp list 2>&1 | sed 's/^/      /' | head -10
	@echo ""
	@echo "    La CLI (npm \`context7\`) es para ti en la shell, no para el agente."
	@echo "    Si la quieres:  make context7-cli"
	@echo ""
	@echo "    El binario ~/.local/bin/context7-mcp es la vía antigua, sin usar."

.PHONY: context7-cli
context7-cli: ## Instala la CLI de context7 para usarla en la terminal
	@$(NPM) i -g --no-fund --no-audit context7
	@echo "    lista: context7 --help"

codegraph: ## Instala el CLI de codegraph (colbymchenry/codegraph)
	@echo "==> codegraph"
	@$(NPM) i -g --no-fund --no-audit @colbymchenry/codegraph
	@echo ""
	@command -v codegraph >/dev/null 2>&1 \
	  && echo "    instalado: $$(command -v codegraph)" \
	  || echo "   AVISO: no aparece en el PATH ($$PATH)"
	@echo ""
	@echo "    El MCP ya está declarado a mano en mcp.servers.codegraph."
	@echo "    NO se ejecuta \`codegraph install\` a propósito: escribe en"
	@echo "    ~/.config/opencode/opencode.jsonc, que es un symlink a este repo,"
	@echo "    y podría sustituirlo por un fichero normal dejando la config"
	@echo "    fuera de git sin avisar."
	@echo ""
	@echo "    Por proyecto hace falta indexarlo:  codegraph init"

codegraph-snippet: ## Imprime el config que codegraph escribiría, sin escribir nada
	@command -v codegraph >/dev/null 2>&1 \
	  || { echo "codegraph no está instalado: make codegraph"; exit 1; }
	@codegraph install --print-config opencode

## ------------------------------------------- lanzadores de opencode
# El TUI no es un subcomando: es `opencode` a secas, con el directorio
# como argumento posicional. Sí existe `opencode mini` para la versión
# mínima, y `opencode serve` para el servidor (que es el de la web).
opencode: ## Abre el TUI de opencode sobre PROJECT
	$(CHECK_PROJECT)
	@$(MAKE) --no-print-directory opencode-tui PROJECT="$(PROJECT)"

# El TUI necesita un target propio porque `make` ejecuta cada receta en su
# propia shell: abrir el TUI en la del padre, y luego cerrarlo, mataba el
# proceso. Con un target intermedio, el TUI se queda con la terminal.
# (Sin la marca ## a proposito: no es un target de uso, no debe salir en help.)
.PHONY: opencode-tui
opencode-tui:
	@opencode "$(PROJECT)"

opencode-web: ## Sirve la web de opencode sobre PROJECT (pide contraseña)
	$(CHECK_PROJECT)
	$(DO_UPGRADE)
	@bash $(REPO)/scripts/opencode-serve.sh start \
		"$(PROJECT)" "$(OPENCODE_PORT)"

## ------------------------------------------- lanzadores de OpenChamber
openchamber-desktop: ## Abre OpenChamber Desktop (ventana nativa) sobre PROJECT
	$(CHECK_PROJECT)
	@echo "⚡ OpenChamber Desktop sobre $(PROJECT)"
	@OPENCHAMBER_PROJECT_DIR="$(PROJECT)" \
		bash "$(REPO)/scripts/openchamber-desktop-wsl.sh"

openchamber-web: ## Sirve la UI web de OpenChamber sobre PROJECT
	$(CHECK_PROJECT)
	$(DO_UPGRADE)
	@echo "⚡ OpenChamber web sobre $(PROJECT)"
	@echo "   Abre http://localhost:$(OPENCHAMBER_PORT) en el navegador"
	@echo ""
	@PATH="$(NPM_PREFIX)/bin:$$PATH" OPENCODE_BINARY="$(HOME)/.opencode/bin/opencode" \
		OPENCHAMBER_OPENCODE_CWD="$(PROJECT)" \
		openchamber serve --host 127.0.0.1 --port $(OPENCHAMBER_PORT)

# Alias. El repo se llamaba _openchamber antes de la fusión y su README
# documentaba `desktop` y `web`; se dejan vivos para no romper a quien lo
# tenga muscle memory o copiado en un README.
desktop: openchamber-desktop ## Alias de openchamber-desktop
web: openchamber-web ## Alias de openchamber-web

## ------------------------------------------------------------- resto
setup: link compat superpowers codegraph ## Enlaza e instala todo
	@$(MAKE) --no-print-directory check

doctor: ## check + lo que ve opencode por su cuenta
	@$(MAKE) --no-print-directory check
	@echo ""
	@echo "--- opencode debug paths ---"
	@opencode debug paths
	@echo ""
	@echo "--- opencode mcp list ---"
	@opencode mcp list
	@echo ""
	@echo "--- instancias de opencode serve ---"
	@bash $(REPO)/scripts/opencode-serve.sh status

stop: ## Detiene los servidores de opencode y de OpenChamber
	@bash $(REPO)/scripts/opencode-serve.sh stop
	@PATH="$(NPM_PREFIX)/bin:$$PATH" openchamber stop --port $(OPENCHAMBER_PORT) || true

status: ## Lista los servidores de opencode y de OpenChamber en marcha
	@bash $(REPO)/scripts/opencode-serve.sh status
	@PATH="$(NPM_PREFIX)/bin:$$PATH" openchamber status || true

upgrade: ## Actualiza plugins, opencode y openchamber
	@opencode plugin update 2>&1 | sed 's/^/   /'
	@echo ""
	@echo "    superpowers va por git, así que esto no lo actualiza."
	@echo "    Para eso: make superpowers   (reinstala desde el repo)"
	@echo ""
	@$(UPGRADE_SH) $(UPGRADE_FLAGS)

clean: ## Borra los temporales de este repo
	@rm -f $(REPO)/scripts/tmp-*.sh
	@echo "   temporales borrados"
