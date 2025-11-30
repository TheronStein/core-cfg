# ~/.core/zsh/modules/ansible.zsh
# Ansible Integration - automation helpers, playbook management, and vault tools

#=============================================================================
# CHECK FOR ANSIBLE
#=============================================================================
(($+commands[ansible])) || return 0

#=============================================================================
# ENVIRONMENT#=============================================================================
#=============================================================================
export ANSIBLE_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/ansible"
export ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ansible/galaxy_cache"
export ANSIBLE_LOCAL_TEMP="${XDG_CACHE_HOME:-$HOME/.cache}/ansible/tmp"
export ANSIBLE_RETRY_FILES_SAVE_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/ansible/retry"

# Colored output
export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_NOCOLOR=0

# Better output formatting
export ANSIBLE_STDOUT_CALLBACK=yaml
# Alternative: export ANSIBLE_STDOUT_CALLBACK=debug

#=============================================================================
# BASE ALIASES
#=============================================================================
alias ans='ansible'
alias ansp='ansible-playbook'
alias ansv='ansible-vault'
alias ansg='ansible-galaxy'
alias ansi='ansible-inventory'
alias ansd='ansible-doc'
alias ansc='ansible-config'

#=============================================================================
# PLAYBOOK ALIASES
#=============================================================================
alias apc='ansible-playbook --check'          # Check mode (dry run)
alias apd='ansible-playbook --diff'           # Show diff
alias apcd='ansible-playbook --check --diff'  # Check + diff
alias apv='ansible-playbook -v'               # Verbose
alias apvv='ansible-playbook -vv'             # More verbose
alias apvvv='ansible-playbook -vvv'           # Very verbose
alias apvvvv='ansible-playbook -vvvv'         # Debug level
alias apl='ansible-playbook --limit'          # Limit hosts
alias apt='ansible-playbook --tags'           # Run specific tags
alias apst='ansible-playbook --skip-tags'     # Skip tags
alias aps='ansible-playbook --step'           # Step through tasks
alias apss='ansible-playbook --start-at-task' # Start at task

#=============================================================================
# VAULT ALIASES
#=============================================================================
alias ave='ansible-vault edit'
alias avc='ansible-vault create'
alias avv='ansible-vault view'
alias avd='ansible-vault decrypt'
alias aven='ansible-vault encrypt'
alias avr='ansible-vault rekey'
alias aves='ansible-vault encrypt_string'

#=============================================================================
# GALAXY ALIASES
#=============================================================================
alias agi='ansible-galaxy install'
alias agir='ansible-galaxy install -r requirements.yml'
alias agl='ansible-galaxy list'
alias agc='ansible-galaxy collection install'
alias agci='ansible-galaxy collection install -r requirements.yml'
alias agr='ansible-galaxy role install'
alias aginit='ansible-galaxy init'

#=============================================================================
# FUNCTIONS: PLAYBOOK EXECUTION
#=============================================================================

# Run playbook with inventory
function ap() {
  local inventory="${1:-inventory}"
  local playbook="${2:-playbook.yml}"
  shift 2 2>/dev/null

  ansible-playbook -i "$inventory" "$playbook" "$@"
}

# Run playbook in check mode
function apc() {
  local inventory="${1:-inventory}"
  local playbook="${2:-playbook.yml}"
  shift 2 2>/dev/null

  ansible-playbook -i "$inventory" "$playbook" --check --diff "$@"
}

# Run playbook on specific host
function aph() {
  local host="$1"
  local playbook="${2:-playbook.yml}"
  shift 2 2>/dev/null

  ansible-playbook -i "$host," "$playbook" "$@"
}

# Run playbook on localhost
function aplocal() {
  local playbook="${1:-playbook.yml}"
  shift 2>/dev/null

  ansible-playbook -i "localhost," -c local "$playbook" "$@"
}

# Quick ad-hoc command
function arun() {
  local pattern="${1:-all}"
  local module="${2:-shell}"
  local args="${3:-hostname}"
  local inventory="${4:-inventory}"

  ansible "$pattern" -i "$inventory" -m "$module" -a "$args"
}

# Ping hosts
function aping() {
  local pattern="${1:-all}"
  local inventory="${2:-inventory}"

  ansible "$pattern" -i "$inventory" -m ping
}

# Gather facts
function afacts() {
  local pattern="${1:-all}"
  local inventory="${2:-inventory}"

  ansible "$pattern" -i "$inventory" -m setup
}

# Gather specific fact
function afact() {
  local pattern="${1:-all}"
  local filter="${2:-*}"
  local inventory="${3:-inventory}"

  ansible "$pattern" -i "$inventory" -m setup -a "filter=$filter"
}

#=============================================================================
# FUNCTIONS: VAULT
#=============================================================================

# Edit vault file with fzf selection
function avef() {
  local file
  file=$(fd --type f '\.yml$|\.yaml$|vault' \
    | fzf --header '╭─ Select vault file ─╮' \
      --preview 'bat --style=numbers --color=always {} 2>/dev/null | head -30')

  [[ -n "$file" ]] && ansible-vault edit "$file"
}

# View vault file with fzf selection
function avvf() {
  local file
  file=$(fd --type f '\.yml$|\.yaml$|vault' \
    | fzf --header '╭─ Select vault file ─╮')

  [[ -n "$file" ]] && ansible-vault view "$file"
}

# Encrypt string interactively
function avstr() {
  local name="$1"
  local value

  if [[ -z "$name" ]]; then
    read -r "name?Variable name: "
  fi

  read -rs "value?Value to encrypt: "
  echo

  ansible-vault encrypt_string "$value" --name "$name"
}

# Decrypt file to stdout (for piping)
function avcat() {
  ansible-vault decrypt --output - "$1"
}

#=============================================================================
# FUNCTIONS: INVENTORY
#=============================================================================

# List inventory
function ail() {
  local inventory="${1:-inventory}"
  ansible-inventory -i "$inventory" --list | jq '.'
}

# Graph inventory
function aig() {
  local inventory="${1:-inventory}"
  ansible-inventory -i "$inventory" --graph
}

# Get host variables
function aihost() {
  local host="$1"
  local inventory="${2:-inventory}"
  ansible-inventory -i "$inventory" --host "$host" | jq '.'
}

# Interactive host selector
function aihosts() {
  local inventory="${1:-inventory}"
  local host

  host=$(ansible-inventory -i "$inventory" --list 2>/dev/null \
    | jq -r '._meta.hostvars | keys[]' \
    | fzf --header '╭─ Select host ─╮')

  [[ -n "$host" ]] && echo "$host"
}

#=============================================================================
# FUNCTIONS: DOCUMENTATION
#=============================================================================

# Search module documentation
function amod() {
  local query="$1"

  if [[ -z "$query" ]]; then
    ansible-doc -l | fzf --header '╭─ Ansible Modules ─╮' \
      | awk '{print $1}' | xargs -r ansible-doc
  else
    ansible-doc "$query"
  fi
}

# List modules matching pattern
function amodl() {
  ansible-doc -l "$@"
}

# Search for modules
function amods() {
  local pattern="$1"
  ansible-doc -l | grep -i "$pattern"
}

#=============================================================================
# FUNCTIONS: PROJECT MANAGEMENT
#=============================================================================

# Initialize new ansible project
function ainit() {
  local name="${1:-ansible-project}"

  mkdir -p "$name"/{group_vars,host_vars,roles,inventory,files,templates}

  cat >"$name/ansible.cfg" <<'EOF'
[defaults]
inventory = inventory/
roles_path = roles/
retry_files_enabled = False
host_key_checking = False
stdout_callback = yaml

[privilege_escalation]
become = True
become_method = sudo
EOF

  cat >"$name/playbook.yml" <<'EOF'
---
- name: Main playbook
  hosts: all
  become: yes
  
  tasks:
    - name: Ping hosts
      ansible.builtin.ping:
EOF

  cat >"$name/inventory/hosts" <<'EOF'
[all]
localhost ansible_connection=local

[webservers]

[dbservers]
EOF

  cat >"$name/requirements.yml" <<'EOF'
---
roles: []

collections:
  - name: ansible.posix
  - name: community.general
EOF

  echo "Created ansible project: $name"
  echo "  - ansible.cfg"
  echo "  - playbook.yml"
  echo "  - inventory/hosts"
  echo "  - requirements.yml"
  echo "  - directories: group_vars, host_vars, roles, files, templates"
}

# Create new role
function arole() {
  local name="$1"
  local role_path="${2:-roles}"

  if [[ -z "$name" ]]; then
    # echo "Usage: arole <name> [role_path]"
    return 1
  fi

  ansible-galaxy role init "$role_path/$name"
  echo "Created role: $role_path/$name"
}

#=============================================================================
# FUNCTIONS: DEBUGGING
#=============================================================================

# Debug playbook syntax
function apsyntax() {
  local playbook="${1:-playbook.yml}"
  ansible-playbook "$playbook" --syntax-check
}

# List tasks in playbook
function aptasks() {
  local playbook="${1:-playbook.yml}"
  local inventory="${2:-inventory}"
  ansible-playbook -i "$inventory" "$playbook" --list-tasks
}

# List hosts for playbook
function aphosts() {
  local playbook="${1:-playbook.yml}"
  local inventory="${2:-inventory}"
  ansible-playbook -i "$inventory" "$playbook" --list-hosts
}

# List tags in playbook
function aptags() {
  local playbook="${1:-playbook.yml}"
  local inventory="${2:-inventory}"
  ansible-playbook -i "$inventory" "$playbook" --list-tags
}

#=============================================================================
# FZF INTEGRATIONS
#=============================================================================

# Select and run playbook
function apf() {
  local playbook
  playbook=$(fd --type f '\.yml$|\.yaml$' | grep -E 'playbook|site|main' \
    | fzf --header '╭─ Select playbook ─╮' \
      --preview 'bat --style=numbers --color=always {} 2>/dev/null | head -50')

  if [[ -n "$playbook" ]]; then
    echo "Running: ansible-playbook $playbook"
    ansible-playbook "$playbook" "$@"
  fi
}

# Select role and view
function arolf() {
  local role
  role=$(fd --type d --max-depth 2 . roles 2>/dev/null \
    | fzf --header '╭─ Select role ─╮' \
      --preview 'cat {}/tasks/main.yml 2>/dev/null | bat -l yaml')

  [[ -n "$role" ]] && ${EDITOR:-nvim} "$role"
}

#=============================================================================
# COMPLETIONS
#=============================================================================

# Add completion for inventory files
function _ansible_inventory() {
  _files -g '*(inventory|hosts)*'
}

# Add completion for playbook files
function _ansible_playbook() {
  _files -g '*.y(a|)ml'
}
