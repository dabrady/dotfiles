SANITIZE = sed -e "/^\$$/d" -e "/^\#/d"

.PHONY: noargs
noargs:
# nope

.PHONY: confirm
confirm:
	@/bin/echo -n "Continue? [y/N] " && read ans && [ $${ans:-N} = y ]

.PHONY: list-missing-ports
list--missing-ports:
	@grep -Fxv -f <(port -q installed | awk '{print $1;}') <(${SANITIZE} macports) | xargs port info
	

.PHONY: ports
ports: list-missing-ports confirm
	@${SANITIZE} macports | sudo xargs port install

SOURCES = bag-of-holding emacs.d hammerspoon pryrc spacemacs.d todo.cfg zprofile zshenv zshrc
DOTS = $(addprefix ~/., ${SOURCES})
.PHONY: dots
dots: RECREATE ?=
dots: LNFLAGS := -sv
ifdef RECREATE
dots: LNFLAGS += -f
endif
dots: $(DOTS) snowflakes
$(DOTS): $(SOURCES)
	@ln ${LNFLAGS} ${PWD}/$(@F:.%=%) $@ || true
.PHONY: snowflakes
snowflakes: oh-my-zsh/custom
	@ln ${LNFLAGS} ${PWD}/oh-my-zsh/custom ~/.oh-my-zsh/custom || true

