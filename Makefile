DRY_RUN ?=
DO := $$( test -z ${DRY_RUN} && echo '' || echo 'echo' )

SANITIZE = sed -e "/^\$$/d" -e "/^\#/d"

.PHONY: noargs
noargs:
# nope

.PHONY: confirm
confirm:
	@/bin/echo -n "Continue? [y/N] " && read ans && [ $${ans:-N} = y ]

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


