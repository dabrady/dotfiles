## User functions

## TODO Finish this function; the dumb output might actually be specific to 'bundle exec', not 'rspec'
# function mrspec {
#   # $@ => rspec args
#   setopt nomultios
#   bundle exec rspec --color --tty --format documentation "$@" 2>&1 >/dev/null |
#     while IFS= read -r line
#     do
#       echo -e "$line" | grep '^WARNING'
#     done
#   setopt multios
# }

# Colorize output of 'make test' in a Go project.
function maketest {
  # Technically `make test -s` also works (as opposed to the '--eval' option), but that silences everything and if
  # the `test` rule ever changes to depend on other rules, I’d miss out on any of that output.
  gmake test --eval='.SILENT:test' "$@" | colout -t gotest
}

# Colorize output of 'go test' in a Go project.
function gotest {
  go test "$@" | colout -t gotest
}

# Find the Docker container IDs for container(s) matching a pattern applied to a line of output from the
# 'docker ps' command.
function dcid {
  docker ps | grep "$@" | awk '{ print $1 }'
}

# Given a port number, identifies the Ruby project associated to the unicorn listening to that port.
function whodat {
  u="$(lsof -ti tcp:$1 2>/dev/null | head -1 | xargs ps -o command= -p 2>/dev/null)"
  if [[ "$u" =~ unicorn ]]; then
    echo "$u" | awk '{print $6}' | awk -F'/' '{print $4}'
  else
    echo "No unicorns are listening to port '$1'"
  fi
}

# Displays a list of Ruby unicorns actively listening to TCP ports.
function unicorns {
  lsof -ti tcp | xargs ps -o command= -p | grep '^unicorn master .*/opt/apps/' | awk '{print $6}' | awk -F'/' '{print $4}'
}

function gitrename {
  git branch -m $1 $2
  git push origin :$1
  git push --set-upstream origin $2
}

function gitbranchdel {
  # Delete remote branch
  echo "Deleting remote branch '$1'..."
  git push origin --delete "$1"
  echo "Done.\n"

  # Delete local branch
  read -q "RESPONSE?Delete local branch as well? (y/n) "
  if [[ "$RESPONSE" = 'y' ]]; then
    echo "\nDeleting local branch '$1'..."
    git branch -d "$1"
    echo "Done."
  fi
}

function rebaseball {
  local working_branch=$(current_branch)
  for branch in `gb | grep -v 'master'`; do
    branch=${branch#'*'}
    [ -z "$branch" ] && continue

    echo "\nRebasing $branch"
    grb master $branch
    [ ! "$?" == "0" ] && return 1

    read -q -u 0 "RESPONSE?Force push $branch? (y/n) "
    if [[ "$RESPONSE" == 'y' ]]; then
      gp -f
    fi
  done
  gco $working_branch
}

# Print out a deduped version of the $PATH.
function dedupPath () {
  echo $PATH | tr ":" "\n" | awk '!seen[$0]++' | tr '\n' ':'
}

# Enhance new branch creation by auto-pushing it.
function gbp {
  git checkout -b "$@"
  git push -u origin $(current_branch)
}

# Get the name of the previous branch/commit you had checked out.
function previous_branch {
	local ref
	ref=$(command git rev-parse --abbrev-ref @{-1} 2> /dev/null) || return
	echo $ref
}

# A special function called by iTerm2 to set/update user-defined variables available to the 'badges' feature.
function iterm2_print_user_vars {
  # currentDir -- The name of the current directory
  iterm2_set_user_var currentDir "$(basename $PWD)"

  # currentTime -- A pretty-formatted time stamp
  iterm2_set_user_var currentTime "$(date +'%I:%M%p')"

  # currentJira -- The name of the current JIRA ticket being worked on
  iterm2_set_user_var currentJira "$JIRA_CURRENT"

  # gitBranch -- The name of the git branch currently checked out, if applicable
  iterm2_set_user_var gitBranch "$(current_branch)"
}

function fixruby {
  local rbv=${$(rbenv local)##ruby-}
  local OPTS=

  read -q "RESPONSE?[db] Reinstall ruby v$rbv(y/n) "
  if [[ "$RESPONSE" = 'y' ]]; then
    echo

    # @see https://github.com/rbenv/ruby-build/issues/1353#issuecomment-573414540
    [[ ! "$rbv" > '2.4.1' ]]
    local is_ancient=$?

    if [[ "$is_ancient" == 0 ]]; then
      echo "[db] Ruby version is ancient, will compile with OpenSSL@1.0"
      OPTS='RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.0)"'
    fi

    echo "[db] Reinstalling..."
    rbenv uninstall "$rbv"
    eval $OPTS rbenv install "$rbv"

    if [[ "$is_ancient" == 0 ]]; then
      echo "[db] Ancient Ruby needs ancient version of bundler..."
      gem install bundler -v '~> 1'
    fi

    echo "[db] Should be fixed now."
  fi
}

# Create a new TODO scoped to the current JIRA.
function ta {
  todo.sh add "$@" +$JIRA_CURRENT
}

function readmd {
  pandoc "$@" | lynx -stdin
}

function gbfix {
  last_common_commit="$(git --no-pager lg -1 --pretty=format:%h --grep="`git --no-pager log -1 --pretty=format:%s $1`")"
  commits_on_this_branch="$(git --no-pager lg --pretty=format:%h --reverse $last_common_commit..)"
  [[ -z "$commits_on_this_branch" ]] && echo 'Nothing to fix.' && return 0

  echo "If something goes wrong, use: git gobak origin/\$(current_branch)\n"
  # echo "These are the cherries: $commits_on_this_branch"

  git gobak master; echo "\nRebasing $1:" && git rebase "$1"

  echo "\nReapplying branch commits:" && (echo $commits_on_this_branch | xargs git cherry-pick)
}

function gls {
  local IFS=$'\n'
  local listing=''

  for line in `ls "$@"`; do
    local fileName=$(echo $line | awk '{print $NF}')
    if [[ "$fileName" == */ ]]; then
      local uncolorizedFileName=$(gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" <<< "$fileName")
      local gitInfo=$(print -P $(GIT_WORK_TREE=$uncolorizedFileName GIT_DIR=$uncolorizedFileName.git git_prompt_info))
      local branch=${gitInfo/git:/}
      branch=${branch/)/}

      listing="$listing\n$line $branch"
    else
      listing=$listing$'\n'$line
    fi
  done
  echo $listing | column -t -s '('
}

# function rspec {
#   # Look for any running rspec-watcher, and send it a signal if it's running.
#   watcherPID=$(ps aux | grep "[r]spec-watcher" | awk '{print $2}')
#   [[ ! -z $watcherPID ]] && kill -USR2 $watcherPID
#   bundle exec rspec -c --format documentation
# }

# Encapsulates necessary environment setup for a local Kubernetes environment.
function localkube_env() {
    local MKBIN=$(which minikube)
    local MYSHELL=$(basename ${SHELL})
    eval $(${MKBIN} docker-env --shell ${MYSHELL} $@) && echo "docker CLI configured to use engine on minikube instance"
    eval $(${MKBIN} completion ${MYSHELL}) && echo "minikube shell completions loaded"
    eval $(kubectl completion ${MYSHELL}) && echo "kubectl shell completions loaded"
    export MINIKUBE_IP="$(${MKBIN} ip $1)"
    export MINIKUBE_SUBNET=$(echo ${MINIKUBE_IP} | awk -F '.' '{ printf("%s.%s.%s.0", $1, $2, $3) }')
    export MINIKUBE_GATEWAY=$(echo ${MINIKUBE_IP} | awk -F '.' '{ printf("%s.%s.%s.1", $1, $2, $3) }')
}
##### Handy one-liners #####

## Append text to all commit messages reachable by git-rebase
# GIT_EDITOR="gsed -i -e '1a\\\n[Contributes to ABC-123]'" GIT_SEQUENCE_EDITOR="gsed -i -e 's/pick/reword/'" git rebase -i
