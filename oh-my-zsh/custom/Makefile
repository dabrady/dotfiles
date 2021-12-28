## TODO just make this a bash script called 'make' that delegates to the real make or runs this thing

SHELL := /opt/local/bin/bash

CONFIG_FILES      := ( [pipenv]=Pipfile            [yarn]=package.json )
RUN_COMMANDS      := ( [pipenv]=run                [yarn]= )
# TODO support Django
# SECONDARY_RUNNERS := ( [django]="python manage.py" )

.PHONY: noargs
noargs:
	@# nope

# Delegate to the first known 'runner' we find.
.PHONY: %
%: ARGS ?=
%: RUNNER_ARGS ?=
%:
	@ declare -A CONFIGS=${CONFIG_FILES}\
	; declare -A RUNNERS=${RUN_COMMANDS}\
	; declare STATUS\
	; for runner in "$${!RUNNERS[@]}"; do\
	  ( for config_file in $${CONFIGS[$$runner]}; do test -f $$config_file || exit 1; done );\
	  if [[ 0 == "$$?" ]]; then\
	    ( set -x; $$runner ${RUNNER_ARGS} $${RUNNERS[$$runner]} $* ${ARGS} );\
	    STATUS=$$?;\
			break;\
		fi\
	; done;\
	if [[ -z "$$STATUS" ]]; then\
	  echo "Can't do anything here.";\
	  exit 1;\
	else\
	  exit $$STATUS;\
	fi\
