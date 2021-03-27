# Update JIRA environment variables
function cj {
  local jira_config=$HOME/.jira
  local jira="$1"

  # Sync in case unset or manually changed.
  . $jira_config

  # Do nothing if nothing given.
  [[ -z "$jira" ]] && echo "Currently tracking $JIRA_CURRENT." && return 0

  if [[ $jira == '-' ]]; then
    jira=$JIRA_PREVIOUS
  fi

  if [[ $JIRA_CURRENT != $jira ]]; then
    gsed -i "/JIRA_PREVIOUS/s/=.*/=$JIRA_CURRENT/" $jira_config
    gsed -i "/JIRA_CURRENT/s/=.*/=$jira/" $jira_config

    . $jira_config

    # Refresh any running Emacs environment, too.
    ps aux | grep '[E]macs --bg-daemon' >/dev/null
    if [[ "$?" == "0" && "$EMACS_DAEMON" != "" ]]; then
      true
      # TODO(dabrady) Figure out why this actually strips away the double quotes from the Emacs input
      # emacsclient -ne --socket-name=$EMACS_DAEMON "(change-jira \"$jira\")" >/dev/null
    fi

    echo "Now tracking $jira."
  fi
}

function cd_and_cj {
  \cd "$@"
  # TODO(dabrady) Consider clearing the current JIRA if not in a Tapjoy project.
  # do nothing further if not a git repo
  _=$(command git symbolic-ref HEAD 2> /dev/null) || _=$(command git rev-parse --short HEAD 2> /dev/null)
  if [[ "$?" == "0" && "$PWD" == *github/tap* ]]; then
    ticket=$(current_branch | egrep '[A-Z]+-\d+' -o)
    cj $ticket
  else
    cj ' ' #> /dev/null
  fi
}
