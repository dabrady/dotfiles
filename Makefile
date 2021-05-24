DRY_RUN ?=
DO := $$( test -z ${DRY_RUN} && echo '' || echo 'echo' )

SANITIZE = sed -e "/^\$$/d" -e "/^\#/d"

.PHONY: noargs
noargs:
# nope

.PHONY: confirm
confirm:
	@/bin/echo -n "Do the thing? [y/N] " && read ans && [ $${ans:-N} = y ]

.PHONY: add-to-%
add-to-%: CMD ?=
add-to-%: COMMENT ?=
add-to-%:
	@echo "Appending '${CMD}' to $*..."
	@${DO} printf "\n### ${COMMENT}\n${CMD}\n" >> $*

## NOTE(dabrady) Just playing with something
# %-access-check:
# 	@test -w $*

# INSTALL_DIR ?= /Applications
# foo: ${INSTALL_DIR}-access-check
# 	@echo 'we good'

## Generate any missing dotted symlinks to source config.
SOURCES = authinfo.gpg bag-of-holding emacs.d hammerspoon oh-my-zsh/custom pryrc spacemacs.d todo.cfg zprofile zshenv zshrc
dots: $(addprefix ~/., ${SOURCES})
~/.%: %
	@${DO} ln -sv ${PWD}/$* $@

.PHONY: list-missing-ports
list-missing-ports: INSTALLED_PORTS := $$(port -q installed | awk '{print $1;}')
list-missing-ports: DESIRED_PORTS := $$(${SANITIZE} macports)
list-missing-ports:
	@${DO} grep -Fxv -f ${INSTALLED_PORTS} ${DESIRED_PORTS} | ${DO} xargs port info

.PHONY: ports
ports: list-missing-ports confirm
	@${DO} ${SANITIZE} macports | ${DO} sudo xargs port install

OTHER_THINGS = iterm asdf
.PHONY: install
install: $(addprefix install-,${OTHER_THINGS})

.PHONY: install-iterm
# Check if we have write access to the install directory; if not, use sudo.
install-iterm: INSTALL_DIR ?= /Applications
install-iterm: MAYBE_SUDO := $$(test -w ${INSTALL_DIR} && echo '' || echo 'sudo')
install-iterm: RELEASE_ARTIFACT ?= "$${HOME}/Downloads/iTerm.zip"
install-iterm: SHELL := zsh
install-iterm:
	@echo "---- Installing iTerm shell ----"
	@$(MAKE) confirm &&\
	  (\
    test "${MAYBE_SUDO}" = "sudo" && echo "⚠️  Heads up: we'll need sudo for this!" &&\
		echo "Downloading iTerm2..." &&\
	  ${DO} curl -L https://iterm2.com/downloads/stable/latest -o ${RELEASE_ARTIFACT} &&\
	  echo "Installing iTerm2..." &&\
	  ${DO} ${MAYBE_SUDO} unzip -q -d ${INSTALL_DIR} ${RELEASE_ARTIFACT} &&\
	  ${DO} rm -rf ${RELEASE_ARTIFACT} &&\
	  ${DO} curl -L https://iterm2.com/shell_integration/${SHELL} -o ~/.iterm2_shell_integration.${SHELL} &&\
	  echo "NOTE(dabrady): Make sure to 'source ~/.iterm2_shell_integration.${SHELL}' in ${SHELL} config" ;\
	  ) || true &&\
	  echo "Done.\n"

.PHONY: install-asdf
install-asdf:
	@echo "---- Installing ASDF version manager ----"
	@$(MAKE) confirm &&\
	  (\
	  ${DO} git clone https://github.com/asdf-vm/asdf.git ~/.asdf &&\
	  ${DO} git -C ~/.asdf checkout "$$(${DO} git -C ~/.asdf describe --abbrev=0 --tags)" &&\
	  ${DO} $(MAKE) add-to-zshrc \
      CMD='source ~/.asdf/asdf.sh' \
      COMMENT='Initialize ASDF version manager' ;\
	  ) || true &&\
	  echo "Done.\n"
