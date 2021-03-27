function minikube_is_alive {
  [[ "Running" == "$(minikube status -f '{{.Kubelet}}')" ]]
}

function verbose {
  [[ -z "$@" ]] && return 0
  echo "`tput setaf 5`$@`tput sgr0`"
  eval $@
}

function kguard {
  if minikube_is_alive; then
    verbose $@
  else
    echo "turn on localdev first"
    return 1
  fi
}

# Find the Kubernetes pod name matching a pattern applied to a line of output from the
# 'kubectl get pod' command.
function kpname {
  kguard kubectl get pod | grep "$@" | head -1 | awk '{ print $1 }'
}

function kwait {
  local timeout="$1"
  [[ "$#" -gt "0" ]] && shift
  local pod=$(kpname ${1})
  [[ -z "$pod" ]] && echo "pod matching '$1' not found" && return 1
  [[ "$#" -gt "0" ]] && shift

  verbose "kubectl wait --for=condition=ready 'pod/$pod' --timeout=$timeout >/dev/null" &&\
  verbose $@
}

alias kgetall='kguard kubectl get pods'
function kget {
  kguard kubectl get pod -l app="$1"
}

function klogs {
  local pod=$(kpname ${1})
  [[ -z "$pod" ]] && echo "pod matching '$1' not found" && return 1
  [[ "$#" -gt "0" ]] && shift

  ## Check if pod is ready
  kwait 0 $pod >/dev/null 2>&1
  # verbose kubectl wait --for=condition=ready "pod/$pod" --timeout=0 >/dev/null 2>&1
  if [[ "$?" != 0 ]]; then
    local timeout=300s
    echo "waiting <=$timeout for pod '$pod' to get ready"
    kwait $timeout $pod || return 1
    # verbose kubectl wait --for=condition=ready "pod/$pod" --timeout=$timeout || return 1
  fi

  verbose kubectl logs -f "$pod" --container app "$@"
}

function kellogs {
  local pod=$(kpname ${1})
  [[ -z "$pod" ]] && echo "pod matching '$1' not found" && return 1
  [[ "$#" -gt "0" ]] && shift

  local containers=$(kubectl get pod "$pod" -o=jsonpath='{range .spec.containers[*]}{.name} {end}')
  printf "\033]1337;Custom=id=%s:%s\a" "super-secret-logging-script" "logs-for-$pod $containers"
}

function kexec {
  local pod=$(kpname ${1})
  [[ "$#" -gt "0" ]] && shift

  verbose kubectl exec --stdin --tty "$pod" --container app -- "$@"
}

function kshell {
  local pod=$(kpname ${1})
  [[ "$#" -gt "0" ]] && shift

  kexec "$pod" bash "$@"
}

function kdel {
  local pod=$(kpname ${1})
  [[ "$#" -gt "0" ]] && shift

  verbose kubectl delete pod "$pod" "$@"
}
