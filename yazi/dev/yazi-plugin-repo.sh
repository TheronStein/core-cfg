#!/bin/bash
PLUGIN_NAME=${1:-new-yazi-plugin-{timestamp}}
DESCRIPTION=${2:-"$PLUGIN_NAME: A plugin for Yazi"}
REMOTE_NAME=${3:-origin}
PRIVATE=${4:-true}

get_yazi_plugin_names() {
  for dir in "$YAZI_DEV_PLUGINS"/*.yazi; do
    if [ -d "$dir" ]; then
      PLUGIN_BASENAME=$(basename "$dir" .yazi)
      YAZI_PLUGIN_NAMES+=("$PLUGIN_BASENAME")
      YAZI_PLUGIN_COUNT=${#YAZI_PLUGIN_NAMES[@]}
    fi
  done
}

YAZI_PLUGIN_NAMES+=get_yazi_plugin_names
YAZI_PLUGIN_PATH="$CORECFG/yazi/dev/"

PLUGIN_PATH="$YAZI_PLUGIN_PATH/$PLUGIN_NAME.yazi"
PLUGIN_PASSED=()
PLUGIN_FAILED=()

# VALIDATION VARIABLES
VALIDATION_STRINGS=("Environment Path", "Dev Plugin Path", "Plugin Information", "Github Repository")
VALIDATION_PLUGINS=2
VALIDATION_FAILED=()
VALIDATION_PASSED=()

TIMESTAMP=$(date +%H%M%S)
DATESTAMP=$(date +%Y%m%d)

log_header() {
  local log_file="$HOME/.core/.logs/yazi-dev-$DATESTAMP.log"
  {
    echo "=============================="
    echo "Yazi Dev Plugin Repo Log"
    echo "Date: $(date +%Y-%m-%d)"
    echo "Time: $(date +%H:%M:%S)"
    echo "=============================="
    echo ""
  } >> "$log_file"
}

log_entry() {
  local MESSAGE="$1"
  local LOG_FILE="$HOME/.core/.logs/yazi-dev-$DATESTAMP.log"
  local CONTEXT="[CORE_VAULT]"
  echo "[$TIMESTAMP] $CONTEXT: $message" >> "$log_file"
}

log_proc_header() {
  local process_name="$1"
  log_entry "Initializing: $process_name"
}

create_log() {
  local log_dir="$HOME/.core/.logs"
  if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
  fi
  local log_file="$log_dir/yazi-dev-$DATESTAMP.log"
  touch "$log_file"
  log_header
  log_entry "Log file created at $log_file"
}

validation_proc_init() {
  log_proc_header "Validation Procedure Initialization"
  log_entry "Validations to be performed: ${#VALIDATION_STRINGS[@]}"
  log_entry "Starting validation checks..."

for validation in "${VALIDATION_STRINGS[@]}"; do
  echo "Performing validation: $validation"
  case "$validation" in
    "Environment Path")
      validate_env_path
      ;;
    "Dev Plugin Path")
      validate_plugin_path
      ;;
    "Plugin Information")
      validate_plugin_info
      ;;
    "Github Repository")
      validate_repo_exist
      ;;
    *)
      echo "Unknown validation: $validation"
      ;;
  esac
done
}

env_structure() {
  echo "Identifying Environment Structure..."
  echo "Searching for CORECFG in common shell configuration files..."
  local config_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
  
   for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
      if grep -q "CORECFG" "$file"; then
        echo "Found CORECFG in $file:"
        grep "CORECFG" "$file"
      fi
    fi
  done
  echo "Please ensure that CORECFG is set correctly in your shell configuration."
}

env_checks() {
  CORE_ENV_DIRS=( \
    "$HOME/.core" \ 
    "$HOME/.core/.sys" \
    "$CORE_CFG" \ 
    "$CORE_CFG/yazi" \
    "$CORE_CFG/yazi/dev" \ 
    "$HOME/.core/.sys/.configs/yazi/dev/plugins" \
)

  CORE_ENV_DIRS_FOUND=()
  for dir in "${CORE_ENV_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      CORE_ENV_DIRS_FOUND+=("$dir")
      log_entry "Found CORE environment directory: $dir"
    else
      log_entry "CORE environment directory not found: $dir"
      MISSING_DIR=env_search "$dir"
      if [ -n "$MISSING_DIR" ]; then
        log_entry "Located missing directory at: $MISSING_DIR"
        return 0
      else
        log_entry "Could not locate missing directory: $dir"
        env_search "yazi/dev/plugins"
      fi
    fi
  done

  local CORE_ROOT_DIR="$HOME/.core"
  if [ -d "$CORE_ROOT_DIR" ]; then
    echo "Found CORE root directory at $CORE_ROOT_DIR"
  else
    echo "CORE root directory not found at $CORE_ROOT_DIR"
    
  fi



env_handler() {
  log_entry "Initiliating Environment Handling..."
  if [ -z "$CORECFG" ]; then
    log_entry "CORECFG is not set. Attempting to identify environment structure."
  else
    log_entry "CORECFG is set to: $CORECFG"
  fi
}

try_failed_handler() {
  local validation_name="$1"
  log_entry "Attempting failed handler for validation: $validation_name"
  failed_handler "$validation_name"
}

validate_env() { 
  log_entry "Validating Environment Path..."
  FIND_ENV_PATH=validate_env_path
  if $FIND_ENV_PATH; then
    VALIDATION_PASSED+=("Environment Path")
    log_entry "Environment Path validation passed."
  else
    VALIDATION_FAILED+=("Environment Path")
    log_entry "Environment Path validation failed."
    try_failed_handler "Environment Path" 
  fi
}

plugin_get_information() {
  echo "Retrieving Plugin Information..."
  
  PLUGIN_NAME="$1"
  PLUGIN_DESCRIPTION="$2"
  REMOTE_NAME="$3"
  PLUGIN_COUNT=$(count_yazi_plugins)
}


validate_plugin_path() {
#Plugin Root Path Validation
  $FIND_PLUGIN_PATH; then
      VALIDATION_PASSED+=("Dev Plugin Path")
      log_entry "Dev Plugin Path validation passed."
    else
      VALIDATION_FAILED+=("Dev Plugin Path")
      log_entry "Dev Plugin Path validation failed."
      try_failed_handler "Plugin Path"
    fi
  done

}

failed_handler() {
  local validation_name="$1"
  echo "Handling failure for validation: $validation_name"
  case "$validation_name" in
    "Environment Path")
      #TODO: Add script for zsh environment handling, providing logs where the variable is set, what it's set to and case handling attempts to fix it automatically.
      echo "Please set the CORECFG environment variable to the correct path."
      identify_env_structure
      ;;
    "Plugin Path")
      echo "Attempting to create plugin path..."
      create_plugin_path
      ;;
    "Github Repository")
      echo "Repository already exists. Please choose a different plugin name."
      ;;
    *)
      echo "No specific handler for validation: $validation_name"
      ;;
  esac
}


validate_env_path() {
  echo "Validating Environment Variable..."
  if [ -z "$CORECFG" ]; then
    #TODO: Add script for zsh environment handling, providing logs where the variable is set, what it's set to and case handling attempts to fix it automatically.
    echo "Error: CORECFG environment variable is not set."
    return 1
  elif [ "$CORECFG" ] ; then
    echo "Environment variable validation passed."
    echo "CORECFG is set to: $CORECFG"
    return 0
  else
    echo "Error: Unexpected error validating Environment Variable CORECFG."
    return 2
  fi
}

validate_plugin_path() {
  echo "Validating Plugin Path..."
  if [ -z "$CORECFG/yazi/dev/$PLUGIN_NAME.yazi" ]; then
    echo "Error: Plugin path is not set."
    return 1
  else
    echo "Plugin path validation passed."
    echo "Plugin Path: $CORECFG/yazi/dev/$PLUGIN_NAME.yazi"
    return 0
  fi
}

create_plugin_path() {
  echo "Creating Plugin Path..."
  mkdir -p "$CORECFG/yazi/dev/$PLUGIN_NAME.yazi"
  if [ $? -eq 0 ]; then
    echo "Plugin path created successfully."
    return 0
  else
    echo "Error: Failed to create plugin path."
    return 1
  fi
}

  # if [ -z "" ]; then
  #   echo "Error: Plugin name is required."
  #   return 1
  # else
  #   return 0
  # fi
}

validate_repo_exist() {
  if gh repo view $CORECFG/yazi/dev/$PLUGIN_NAME.yazi > /dev/null 2>&1; then
    echo "Error: Repository $CORECFG/yazi/dev/$PLUGIN_NAME.yazi already exists."
    return 1
  else 
    return 0
  fi
}

validation_handler() {

for VALIDATION_CHECKS; do 

}

print_validation_results() {
echo "Validation Checks Completed."
echo "Validation Results:"
echo "-------------------"
PASSED=${#VALIDATIONS_PASSED[@]}
FAILED=${#VALIDATION_FAILED[@]}
echo "Total Validations: $VALIDATION_CHECKS"
echo "Validations Passed: $PASSED"
for in "${VALIDATIONS_PASSED[@]}"; do
  echo "  - ${VALIDATIONS_PASSED[$i]}"
done
echo "Validations Failed: $FAILED"
for in "${VALIDATION_FAILED[@]}"; do
  echo "  - ${VALIDATION_FAILED[$i]}"
done
}

main() {
  create_log


  initialize_validation_checks
  }


for i in "${!VALIDATION_NAMES[@]}"; do
    validation_proc="${VALIDATION_NAMES[$i]}"
    if $validation_proc; then
      VALIDATIONS_PASSED+=("${VALIDATION_NAMES[$i]}")
    else
      VALIDATION_FAILED+=("${VALIDATION_NAMES[$i]}")
    fi
  done

  validation_proc

  if [ ${#VALIDATION_FAILED[@]} -eq 0 ]; then
    create_repo
  else
    echo "Repository creation aborted due to validation failures."
    exit 1
  fi


gh repo create $CORECFG/yazi/dev/$PLUGIN_NAME.yazi --description "$DESCRIPTION" --remote $REMOTE_NAME --push
