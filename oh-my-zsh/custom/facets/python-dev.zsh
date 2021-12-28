event on _CD_ try_to_activate_python_if_it_makes_sense
function try_to_activate_python_if_it_makes_sense() {
  # Pipfiles tell us required Python versions. If there isn't one, we can't infer anything.
  if [[ ! -e Pipfile ]]; then return 0; fi

  local current_pyversion=$(python --version 2>&1 | awk '{print $2;}')
  local required_pyversion=$(divine_python_version_from_pipfile) # might be empty
  local conda_env_activated=$(test ! -z $CONDA_PREFIX; echo $?)

  # If we're already in a virtual environment and it's good enough, that's good enough.
  if [[ 0 -eq $conda_env_activated && $current_pyversion == $required_pyversion* ]]; then return 0; fi

  local best_pyenv=$(select_conda_env_for_python_version $required_pyversion)
  local postactivate='python --version'

  # If we don't have a suitable virtual environment, prompt to make one.
  if [[ -z $best_pyenv ]]; then
    read -q "RESPONSE?[db] No suitable env exists for working with Python $required_pyversion. Create one? (y/n) "
    if [[ ! "$RESPONSE" = 'y' ]]; then echo && return 0; fi
    echo

    local tmpfile=$(mktemp)
    newpy $required_pyversion | tee "$tmpfile"

    best_pyenv=$(cat $tmpfile | pcre2grep -o1 "conda activate (.*)")
    rm $tmpfile
  fi

  # Put on our Sunday best.
  activate $best_pyenv
  eval "${postactivate}"
}

function deactivate() {
  ${DEBUG} "[db] Deactivating $CONDA_DEFAULT_ENV"
  conda deactivate
  alias exit >/dev/null && unalias 'exit'
  return 0
}

function activate() {
  local DEFAULT_PYTHON_ENV=py37 # just a preference and not a strong one
  local v_env=${1:-$DEFAULT_PYTHON_ENV}

  # Deactivate current session
  test -z $CONDA_PREFIX || deactivate
  # Activate the provisioned conda environment
  ${DEBUG} "[db] Activating $v_env"
  conda activate $v_env

  # Get ahead of habits
  alias exit >/dev/null || alias exit=deactivate

  # Turn on pipenv completions
  (type pipenv >/dev/null) && eval "$(pipenv --completion)"
}

# Creates a new Conda environment for working with the given Python version.
function newpy() {
  local py_version=$1
  local env_name=${2:-"py${1//./}"}

  # Check if an env for this Python version already exists
  local py_envs=$(conda_envs_for_python $py_version)
  if [[ ! -z "$py_envs" ]]; then
    echo "at least one conda env exists with that python version: consider using one of those instead:\n"
    echo $py_envs
    return 1
  fi

  # Check if name is taken
  conda env list | grep -w $env_name >/dev/null
  if [[ ! 1 -eq $? ]]; then
    echo "conda env '${env_name}' already exists, try again"
    return 1
  fi

  # All clear, create a new one with pipenv already installed
  conda create --name $env_name python=$py_version pipenv
}

function divine_python_version_from_pipfile() {
  if [[ ! -e Pipfile ]]; then
    return 1;
  fi
  pcre2grep -o1 "python_version\s*=\s*['\"](.*)['\"]" Pipfile
}

# NOTE(dabrady) if ever needed, this is generalizable for any conda package: just
# parameterize 'python' in the `conda search` command.
function conda_envs_for_python() {
  # If no version is given this finds all envs with Python installed
  local py_envs=$(conda search --envs python=$1)

  # conda-search has dumb output, so this is how we're stuck checking for "no results" 😒
  if [[ $(echo $py_envs | wc -l | xargs) -lt 3 ]]; then
    return 1
  fi

  ## Fancy and entirely overkill output formatting, which I can indulge in because this is my life 😄
  # replace conda output header with mine
  echo "Env\tPython\n---\t---"
  echo $py_envs | tail -n +3 |\
    # extract the Python version and env location
    awk '{print $2,$5}' |\
    # re-order them by descending Python version
    sort --reverse |\
    # format the info nicely for our viewers
    awk '{ "basename " $2 | getline name; sub(/miniforge3/, "base", name); printf("%s\t%s\n", name, $1);}'
  return 0
}

function select_conda_env_for_python_version() {
  local py_envs=$(conda_envs_for_python $1)

  local finder_cmd
  if [[ -z "$1" ]]; then
    finder_cmd="tail -n +3"
  else
    finder_cmd='grep $1'
  fi
  # Just choose the first result, they're ordered descending by version.
  echo $py_envs | eval $finder_cmd | head -1 | awk '{print $1;}'
}
