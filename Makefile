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

