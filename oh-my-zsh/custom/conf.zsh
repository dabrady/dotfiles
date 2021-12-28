########################################
# User configuration
#########################################
DEBUG='echo'
DEBUG=':' # NOTE(dabrady) Comment this out to enable debug logging

# I've started organizing config such as functions and aliases into namespaced "facets".
for file ($ZSH_CUSTOM/facets/*.zsh(N)); do
  source $file
done
unset file

# A sort of 'hook' system for executing code upon changing directories.
function cd() {
  builtin cd "$@"
  event emit _CD_
}

# Fallback to personal "global" Makefile
function make() {
  if [[ -a Makefile ]]; then
    /usr/bin/make "$@"
  else
    ( set -x; /usr/bin/make -f $ZSH_CUSTOM/Makefile "$@" )
  fi
}

function exit() {
  # NOTE Emitting the event _before_ issuing the command, so that any synchronous
  # processing happens before we actually kill the session.
  event emit _EXIT_
  builtin exit "$@"
}
# Enable more powerful globbing
setopt extended_glob

# For riak happiness, upgrade open file limit
ulimit -n 200000
ulimit -u 2048
