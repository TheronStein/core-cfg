# Get the workspace directory from the current pane's path
# This function will check parent directories for a .devcontainer directory,
# and return the path to the workspace directory.
get_workspace_dir() {
  local current_dir="$(get_current_pane_path)"

  current_dir=$(realpath "$current_dir")

  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/.devcontainer" ]]; then
      break
    fi
    current_dir=$(dirname "$current_dir")
  done

  if [[ "$current_dir" == "/" ]]; then
    echo ""
  else
    echo "$current_dir"
  fi
}

get_devcontainer_config() {
  # debug "Getting devcontainer config for key path: $1 with default value: $2"
  local key_path="$1"
  local default_value="$2"

  # TODO: Memoize this function to avoid multiple calls to devcontainer read-configuration?
  local json=$(devcontainer read-configuration --workspace-folder "$(get_workspace_dir)" 2>/dev/null)

  local value=$(echo "$json" | jq -r "${key_path} // \"\"")

  if [ ! -z "$value" ]; then
    echo "$value"
  else
    echo "$default_value"
  fi
}

check_workspace() {
  if [[ -z $(get_workspace_dir) ]]; then
    tmux display-message "No devcontainer found in the current workspace"
    exit 0
  fi
}

get_exec_command() {
  exec_command=$(get_devcontainer_config ".configuration.customizations.tmux.execCommand" "/bin/bash")
  echo "$exec_command"
}

#####################################################################
# detect_orchestration
# # Detect which orchestration method is used in the devcontainer
# #####################################################################
detect_orchestration() {
  local devcontainer_config="$1"
  local orchestrator=""

  if [[ -n $(echo $devcontainer_config | jq -r '.dockerComposeFile // ""') ]]; then
    orchestrator="compose"
  elif [[ -n $(echo $devcontainer_config | jq -r '.dockerFile // ""') ]]; then
    orchestrator="docker"
  elif [[ -n $(echo $devcontainer_config | jq -r '.image // ""') ]]; then
    orchestrator="image"
  else
    orchestrator="none"
  fi

  echo "${orchestrator}"
}

#####################################################################
# get_docker_compose_files
#
# Try to get the the docker compose files from the devcontainer config
# and return their full path
#####################################################################
get_docker_compose_files() {
  local devcontainer_config="$1"
  local compose_files=$(echo "$devcontainer_config" | jq -r ".dockerComposeFile | arrays // [.] | .[]")
  local workspace_dir=$(get_workspace_dir)
  local compose_files_full_path=""

  for compose_file in ${compose_files}; do
    compose_files_full_path="${compose_files_full_path} ${workspace_dir}/.devcontainer/${compose_file}"
  done

  echo "${compose_files_full_path}"
}
