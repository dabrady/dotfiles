SANITIZE = sed -e "/^\$$/d" -e "/^\#/d"

.PHONY: noargs
noargs:
# nope
	${SANITIZE}

.PHONY: confirm
confirm:
	@/bin/echo -n "Continue? [y/N] " && read ans && [ $${ans:-N} = y ]

.PHONY: list-ports
list-ports:
	@${SANITIZE} macports | xargs port info
	

.PHONY: ports
ports: list-ports confirm
	@${SANITIZE} macports | sudo xargs port install

