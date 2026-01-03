event on _CD_ try_to_activate_python_if_it_makes_sense
function try_to_activate_python_if_it_makes_sense() {
  local required_pyversion
  local tool_versions_file

  # First, try to find Python version from Pipfile
  if [[ -e Pipfile ]]; then
    required_pyversion=$(divine_python_version_from_pipfile)
  elif [[ -e pyproject.toml ]]; then
    # If no Pipfile, check for pyproject.toml
    required_pyversion=$(divine_python_version_from_pyproject_toml)
  else
    # If no Pipfile or pyproject.toml, check for .tool-versions file
    tool_versions_file=$(find_tool_versions_file)
    if [[ -n "$tool_versions_file" ]]; then
      required_pyversion=$(divine_python_version_from_tool_versions "$tool_versions_file")
    fi
  fi

  # If we couldn't determine a required version, bail out
  if [[ -z "$required_pyversion" ]]; then return 0; fi

  local current_pyversion=$(python --version 2>&1 | awk '{print $2;}')
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
  # NOTE(dabrady) Disabling this, it's broken in newer versions of pipenv.
  # @see https://github.com/pypa/pipenv/issues/4991#issuecomment-1070960962
  ## (type pipenv >/dev/null) && eval "$(pipenv --completion)"
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
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  # Create symlink in $HOME/bin pointing to the new conda Python
  create_python_symlink "$env_name" "$py_version"
}

# Creates a symlink in $HOME/bin pointing to the Python executable in a conda environment
function create_python_symlink() {
  local env_name="$1"
  local py_version="$2"

  # Extract major.minor version (e.g., 3.12.12 -> 3.12)
  local major_minor=$(echo "$py_version" | pcre2grep -o1 "^([0-9]+\.[0-9]+)")
  if [[ -z "$major_minor" ]]; then
    echo "Warning: Could not extract major.minor version from $py_version, skipping symlink creation"
    return 0
  fi

  # Ensure $HOME/bin exists
  if [[ ! -d "$HOME/bin" ]]; then
    mkdir -p "$HOME/bin"
  fi

  local symlink_path="$HOME/bin/python${major_minor}"
  local python_path=$(conda run -n $env_name which python 2>/dev/null)
  
  if [[ -z "$python_path" ]]; then
    echo "Warning: Could not find Python executable in conda environment $env_name, skipping symlink creation"
    return 0
  fi

  # Create symlink if it doesn't exist, or update it if it does
  local ln_result=0
  if [[ -L "$symlink_path" ]]; then
    echo "Updating existing symlink $symlink_path -> $python_path"
    ln -sf "$python_path" "$symlink_path"
    ln_result=$?
  elif [[ -e "$symlink_path" ]]; then
    echo "Warning: $symlink_path exists and is not a symlink, skipping symlink creation"
    return 0
  else
    echo "Creating symlink $symlink_path -> $python_path"
    ln -s "$python_path" "$symlink_path"
    ln_result=$?
  fi

  if [[ $ln_result -ne 0 ]]; then
    echo "Warning: Failed to create symlink $symlink_path"
    return 0
  fi
}

function divine_python_version_from_pipfile() {
  if [[ ! -e Pipfile ]]; then
    return 1;
  fi
  pcre2grep -o1 "python_version\s*=\s*['\"](.*)['\"]" Pipfile
}

# Extracts Python version from pyproject.toml's requires-python field
function divine_python_version_from_pyproject_toml() {
  if [[ ! -e pyproject.toml ]]; then
    return 1
  fi
  # Extract requires-python value (handles both single and double quotes)
  local version_spec=$(pcre2grep -o1 "requires-python\s*=\s*['\"](.*)['\"]" pyproject.toml | head -1)
  if [[ -z "$version_spec" ]]; then
    return 1
  fi
  # Parse version specifier to extract major.minor version
  parse_python_version_specifier "$version_spec"
}

# Parses Python version specifiers (e.g., "~=3.11", ">=3.11", "==3.11.*") and extracts major.minor version
# Reference: https://packaging.python.org/en/latest/specifications/version-specifiers/#version-specifiers
function parse_python_version_specifier() {
  local spec="$1"
  if [[ -z "$spec" ]]; then
    return 1
  fi
  
  # Handle comma-separated specifiers (take the first one)
  spec=$(echo "$spec" | cut -d',' -f1 | xargs)
  
  # Extract major.minor version from various specifier formats:
  # ~=3.11 -> 3.11
  # >=3.11 -> 3.11
  # ==3.11.* -> 3.11
  # ==3.11.0 -> 3.11
  # >3.11 -> 3.11
  # <3.12 -> 3.12 (though this is less useful, we'll extract it anyway)
  local version=$(echo "$spec" | pcre2grep -o1 "(?:~=|>=|<=|==|>|<|!=)\s*([0-9]+\.[0-9]+)" | head -1)
  
  if [[ -n "$version" ]]; then
    echo "$version"
    return 0
  fi
  
  return 1
}

# Finds a .tool-versions file by walking up the directory tree (up to 3 levels)
# and then checking $HOME/.tool-versions
function find_tool_versions_file() {
  local current_dir="$PWD"
  local levels=0
  local max_levels=3

  # Walk up the directory tree
  while [[ $levels -le $max_levels ]]; do
    if [[ -e "$current_dir/.tool-versions" ]]; then
      echo "$current_dir/.tool-versions"
      return 0
    fi
    # Move up one level
    current_dir=$(dirname "$current_dir")
    # Stop if we've reached $HOME
    if [[ "$current_dir" == "$HOME" ]]; then
      break
    fi
    ((levels++))
  done

  # Check $HOME/.tool-versions as a last resort
  if [[ -e "$HOME/.tool-versions" ]]; then
    echo "$HOME/.tool-versions"
    return 0
  fi

  return 1
}

# Extracts Python version from a .tool-versions file
function divine_python_version_from_tool_versions() {
  local tool_versions_file="$1"
  if [[ ! -e "$tool_versions_file" ]]; then
    return 1
  fi
  # Extract Python version from lines like "python 3.11.0" or "python 3.11"
  pcre2grep -o1 "^python\s+([0-9]+\.[0-9]+(?:\.[0-9]+)?)" "$tool_versions_file" | head -1
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
