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
	@ln -sv ${PWD}/$* $@

.PHONY: list-missing-ports
list--missing-ports:
	@grep -Fxv -f <(port -q installed | awk '{print $1;}') <(${SANITIZE} macports) | xargs port info
	

.PHONY: ports
ports: list-missing-ports confirm
	@${SANITIZE} macports | sudo xargs port install


