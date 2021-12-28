## NOTE(dabrady) WIP

# event on _CD_ try_to_activate_terraform_if_it_makes_sense
function try_to_activate_terraform_if_it_makes_sense() {
  local tf_version=$(_divine_terraform_version_from_project)
  if [[ ! "0" == "$?"  ]]; then
    # No `versions.tf` or unrestricted.
    return 0;
  fi

  export TF_VERSION=
}

function _terraform_port_for_version() {
  local target_version="$1"
  local installed=$(port installed requested | pcre2grep -o1 "(terraform-\S*)\s+@$1.*")
  echo $installed
}

function _divine_terraform_version_from_project() {
  if [[ ! -e versions.tf ]]; then
    return 1;
  fi
  pcre2grep -o1 "required_version\s*=\s*['\"](.*)['\"]" versions.tf
}
