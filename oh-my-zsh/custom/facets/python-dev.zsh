function deactivate() {
  conda deactivate
  unalias 'exit'
}
function activate() {
  local DEFAULT_VENV=py37
  local v_env=${1:-$DEFAULT_VENV}
  conda activate $v_env

  # Get ahead of habits
  alias exit=deactivate

  # Turn on pipenv completions
  (type pipenv >/dev/null) && eval "$(pipenv --completion)"
}
