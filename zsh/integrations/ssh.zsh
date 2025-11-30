# vim: nofixeol noendofline
# shellcheck disable=SC2148
# ~/.core/zsh/modules/ssh.zsh
# SSH Integration - key management, agent configuration, and connection helpers

#=============================================================================
# SSH AGENT CONFIGURATION
#=============================================================================
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.socket"

# Start ssh-agent if not running
function ssh-agent-start() {
  if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    eval $(ssh-agent -a "$SSH_AUTH_SOCK" 2>/dev/null)
    echo "SSH agent started"
  else
    export SSH_AGENT_PID=$(pgrep -u "$USER" ssh-agent | head -1)
  fi
}

# Auto-start agent (uncomment to enable)
# ssh-agent-start

#=============================================================================
# SSH KEY MANAGEMENT
#=============================================================================

# List loaded keys
function ssh-keys() {
  echo "╭─ Loaded SSH Keys ─╮"
  ssh-add -l 2>/dev/null || echo "  No keys loaded"
  echo "╰────────────────────╯"
}

# Add default key
function ssh-add-default() {
  ssh-add ~/.ssh/id_ed25519 2>/dev/null \
    || ssh-add ~/.ssh/id_rsa 2>/dev/null \
    || echo "No default key found"
}

# Add key with fzf selection
function ssh-add-select() {
  local key
  key=$(fd --type f '^id_' ~/.ssh --max-depth 1 \
    | grep -v '\.pub$' \
    | fzf --header '╭─ Select SSH key ─╮' \
      --preview 'ssh-keygen -l -f {}')

  [[ -n "$key" ]] && ssh-add "$key"
}

# Remove all keys
function ssh-keys-clear() {
  ssh-add -D
  echo "All SSH keys removed from agent"
}

# Generate new SSH key
function ssh-keygen-new() {
  local name="${1:-id_ed25519}"
  local email="${2:-$(git config user.email)}"
  local key_path="$HOME/.ssh/$name"

  if [[ -f "$key_path" ]]; then
    echo "Key already exists: $key_path"
    read -q "?Overwrite? [y/N] "
    echo
    [[ $REPLY != "y" ]] && return 1
  fi

  ssh-keygen -t ed25519 -C "$email" -f "$key_path"

  echo ""
  echo "Public key:"
  cat "${key_path}.pub"
  echo ""

  # Offer to copy to clipboard
  read -q "?Copy public key to clipboard? [y/N] "
  echo
  if [[ $REPLY == "y" ]]; then
    cat "${key_path}.pub" | wl-copy 2>/dev/null \
      || cat "${key_path}.pub" | xclip -selection clipboard
    echo "Public key copied to clipboard"
  fi
}

# Show public key
function ssh-pubkey() {
  local key="${1:-id_ed25519}"
  local key_path="$HOME/.ssh/${key}.pub"

  if [[ -f "$key_path" ]]; then
    cat "$key_path"
  else
    # Try to find any public key
    key_path=$(fd '\.pub$' ~/.ssh --max-depth 1 | head -1)
    [[ -f "$key_path" ]] && cat "$key_path" || echo "No public key found"
  fi
}

# Copy public key to clipboard
function ssh-pubkey-copy() {
  local key="${1:-id_ed25519}"
  local pubkey=$(ssh-pubkey "$key")

  if [[ -n "$pubkey" ]]; then
    echo -n "$pubkey" | wl-copy 2>/dev/null \
      || echo -n "$pubkey" | xclip -selection clipboard
    echo "Public key copied to clipboard"
  fi
}

#=============================================================================
# SSH CONFIG HELPERS
#=============================================================================

# Edit SSH config
function ssh-config-edit() {
  ${EDITOR:-nvim} ~/.ssh/config
}

# List SSH hosts from config
function ssh-hosts() {
  echo "╭─ SSH Hosts ─╮"
  grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print "  " $2}' \
    || echo "  No hosts configured"
  echo "╰──────────────╯"
}

# Show config for specific host
function ssh-host-info() {
  local host="$1"
  if [[ -z "$host" ]]; then
    host=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}' \
      | fzf --header '╭─ Select host ─╮')
  fi

  [[ -z "$host" ]] && return 1

  echo "╭─ SSH Config: $host ─╮"
  ssh -G "$host" 2>/dev/null | grep -E "^(hostname|user|port|identityfile)" \
    | while read -r line; do
      echo "  $line"
    done
  echo "╰──────────────────────╯"
}

# Add new host to config
function ssh-host-add() {
  local name="$1"
  local hostname="$2"
  local user="${3:-$USER}"
  local port="${4:-22}"

  if [[ -z "$name" || -z "$hostname" ]]; then
    # echo "Usage: ssh-host-add <name> <hostname> [user] [port]"
    return 1
  fi

  cat >>~/.ssh/config <<EOF

Host $name
    HostName $hostname
    User $user
    Port $port
    IdentityFile ~/.ssh/id_ed25519
EOF

  echo "Added host: $name"
}

#=============================================================================
# SSH CONNECTION HELPERS
#=============================================================================

# Interactive SSH connection with fzf
function sshf() {
  local host
  host=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}' \
    | fzf --header '╭─ SSH Connect ─╮' \
      --preview 'ssh -G {} 2>/dev/null | grep -E "^(hostname|user|port)"')

  [[ -n "$host" ]] && ssh "$host"
}

# SSH with tmux session auto-attach
function ssht() {
  local host="$1"
  local session="${2:-main}"

  if [[ -z "$host" ]]; then
    # echo "Usage: ssht <host> [session_name]"
    return 1
  fi

  ssh -t "$host" "tmux attach -t $session 2>/dev/null || tmux new-session -s $session"
}

# SSH with port forwarding
function sshpf() {
  local host="$1"
  local local_port="$2"
  local remote_port="${3:-$local_port}"

  if [[ -z "$host" || -z "$local_port" ]]; then
    # echo "Usage: sshpf <host> <local_port> [remote_port]"
    return 1
  fi

  echo "Forwarding localhost:$local_port -> $host:$remote_port"
  ssh -N -L "${local_port}:localhost:${remote_port}" "$host"
}

# SSH reverse port forward
function sshrpf() {
  local host="$1"
  local remote_port="$2"
  local local_port="${3:-$remote_port}"

  if [[ -z "$host" || -z "$remote_port" ]]; then
    # echo "Usage: sshrpf <host> <remote_port> [local_port]"
    return 1
  fi

  echo "Reverse forwarding $host:$remote_port -> localhost:$local_port"
  ssh -N -R "${remote_port}:localhost:${local_port}" "$host"
}

# SSH SOCKS proxy
function sshsocks() {
  local host="$1"
  local port="${2:-1080}"

  if [[ -z "$host" ]]; then
    # echo "Usage: sshsocks <host> [port]"
    return 1
  fi

  echo "SOCKS proxy on localhost:$port via $host"
  ssh -N -D "$port" "$host"
}

# Quick SSH command execution
function sshcmd() {
  local host="$1"
  shift
  local cmd="$*"

  if [[ -z "$host" || -z "$cmd" ]]; then
    # echo "Usage: sshcmd <host> <command>"
    return 1
  fi

  ssh "$host" "$cmd"
}

# Copy file to remote
function sshcp() {
  local file="$1"
  local host="$2"
  local dest="${3:-~}"

  if [[ -z "$file" || -z "$host" ]]; then
    # echo "Usage: sshcp <file> <host> [destination]"
    return 1
  fi

  scp -r "$file" "${host}:${dest}"
}

# Copy file from remote
function sshget() {
  local host="$1"
  local file="$2"
  local dest="${3:-.}"

  if [[ -z "$host" || -z "$file" ]]; then
    # echo "Usage: sshget <host> <file> [destination]"
    return 1
  fi

  scp -r "${host}:${file}" "$dest"
}

#=============================================================================
# SSH TUNNEL MANAGEMENT
#=============================================================================

# List active SSH tunnels
function ssh-tunnels() {
  echo "╭─ Active SSH Tunnels ─╮"
  ps aux | grep 'ssh.*-[NL]' | grep -v grep \
    | awk '{print "  " $2 ": " $11 " " $12 " " $13}'
  echo "╰───────────────────────╯"
}

# Kill SSH tunnel by PID
function ssh-tunnel-kill() {
  local pid="$1"
  if [[ -z "$pid" ]]; then
    pid=$(ps aux | grep 'ssh.*-[NL]' | grep -v grep \
      | fzf --header '╭─ Select tunnel to kill ─╮' \
      | awk '{print $2}')
  fi

  [[ -n "$pid" ]] && kill "$pid" && echo "Killed tunnel: $pid"
}

#=============================================================================
# KNOWN HOSTS MANAGEMENT
#=============================================================================

# List known hosts
function ssh-known() {
  cat ~/.ssh/known_hosts 2>/dev/null \
    | cut -d' ' -f1 | tr ',' '\n' | sort -u \
    | fzf --header '╭─ Known Hosts ─╮' \
      --preview 'dig +short {}'
}

# Remove host from known_hosts
function ssh-known-remove() {
  local host="$1"
  if [[ -z "$host" ]]; then
    host=$(cat ~/.ssh/known_hosts 2>/dev/null \
      | cut -d' ' -f1 | tr ',' '\n' | sort -u \
      | fzf --header '╭─ Remove from known hosts ─╮')
  fi

  if [[ -n "$host" ]]; then
    ssh-keygen -R "$host"
    echo "Removed: $host"
  fi
}

# Scan and add host key
function ssh-keyscan() {
  local host="$1"
  if [[ -z "$host" ]]; then
    # echo "Usage: ssh-keyscan <host>"
    return 1
  fi

  ssh-keyscan "$host" >>~/.ssh/known_hosts 2>/dev/null
  echo "Added key for: $host"
}

#=============================================================================
# SSH MULTIPLEXING (ControlMaster)
#=============================================================================

# Check if multiplexed connection exists
function ssh-mux-check() {
  local host="$1"
  ssh -O check "$host" 2>/dev/null && echo "Connection active" || echo "No connection"
}

# Stop multiplexed connection
function ssh-mux-stop() {
  local host="$1"
  if [[ -z "$host" ]]; then
    # echo "Usage: ssh-mux-stop <host>"
    return 1
  fi
  ssh -O stop "$host" 2>/dev/null && echo "Stopped connection to $host"
}

#=============================================================================
# ALIASES
#=============================================================================
alias sshe='ssh-config-edit'
alias sshk='ssh-keys'
alias ssha='ssh-add-select'
alias sshh='ssh-hosts'
alias sshi='ssh-host-info'

#=============================================================================
# COMPLETIONS
#=============================================================================
# SSH completion from config
function _ssh_hosts() {
  local hosts
  hosts=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}')
  _describe 'ssh hosts' hosts
}

(($+functions[compdef])) && compdef _ssh_hosts sshf ssht sshpf sshrpf sshsocks sshcmd sshcp sshget ssh-host-info ssh-mux-check ssh-mux-stop

# vim: ft=zsh noai nosi
