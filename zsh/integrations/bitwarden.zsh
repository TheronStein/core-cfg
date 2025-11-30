# ~/.core/zsh/modules/bitwarden.zsh  
# Bitwarden CLI Integration - secure password management from the shell

#=============================================================================
# CHECK FOR BITWARDEN CLI
#=============================================================================
(( $+commands[bw] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export BITWARDENCLI_APPDATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bitwarden-cli"

# Session token (populated by unlock)
export BW_SESSION=""

#=============================================================================
# SESSION MANAGEMENT
#=============================================================================

# Check if logged in
function bw-status() {
    local status=$(bw status 2>/dev/null | jq -r '.status')
    echo "Bitwarden status: $status"
    return $([ "$status" = "unlocked" ] && echo 0 || echo 1)
}

# Login to Bitwarden
function bw-login() {
    local email="${1:-}"
    
    if [[ -z "$email" ]]; then
        read -r "email?Email: "
    fi
    
    BW_SESSION=$(bw login "$email" --raw)
    export BW_SESSION
    
    if [[ -n "$BW_SESSION" ]]; then
        echo "Logged in successfully"
    else
        echo "Login failed"
        return 1
    fi
}

# Unlock vault
function bw-unlock() {
    BW_SESSION=$(bw unlock --raw 2>/dev/null)
    export BW_SESSION
    
    if [[ -n "$BW_SESSION" ]]; then
        echo "Vault unlocked"
    else
        echo "Unlock failed"
        return 1
    fi
}

# Lock vault
function bw-lock() {
    bw lock
    unset BW_SESSION
    echo "Vault locked"
}

# Logout
function bw-logout() {
    bw logout
    unset BW_SESSION
    echo "Logged out"
}

# Auto-unlock wrapper
function bw-ensure-unlocked() {
    local status=$(bw status 2>/dev/null | jq -r '.status')
    
    case "$status" in
        "unlocked")
            return 0
            ;;
        "locked")
            bw-unlock
            ;;
        "unauthenticated")
            bw-login
            ;;
        *)
            echo "Unknown status: $status"
            return 1
            ;;
    esac
}

#=============================================================================
# SEARCH AND RETRIEVE
#=============================================================================

# Search items
function bw-search() {
    bw-ensure-unlocked || return 1
    
    local query="$*"
    bw list items --search "$query" 2>/dev/null | \
        jq -r '.[] | "\(.name) [\(.id)]"'
}

# Get password by name (interactive with fzf)
function bw-get() {
    bw-ensure-unlocked || return 1
    
    local selected
    selected=$(bw list items 2>/dev/null | \
        jq -r '.[] | "\(.name)\t\(.id)"' | \
        fzf --with-nth 1 --delimiter '\t' \
            --header '╭─ Bitwarden Items ─╮' \
            --preview 'bw get item $(echo {} | cut -f2) 2>/dev/null | jq "{name, username: .login.username, uri: .login.uris[0].uri}"')
    
    if [[ -n "$selected" ]]; then
        local id=$(echo "$selected" | cut -f2)
        local password=$(bw get password "$id" 2>/dev/null)
        
        # Copy to clipboard
        if command -v wl-copy &>/dev/null; then
            echo -n "$password" | wl-copy
            echo "Password copied to clipboard (will clear in 30s)"
            (sleep 30 && echo -n "" | wl-copy) &!
        else
            echo "Password: $password"
        fi
    fi
}

# Get password by exact name
function bw-password() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local password=$(bw get password "$name" 2>/dev/null)
    
    if [[ -n "$password" ]]; then
        if command -v wl-copy &>/dev/null; then
            echo -n "$password" | wl-copy
            echo "Password for '$name' copied to clipboard"
            (sleep 30 && echo -n "" | wl-copy) &!
        else
            echo "$password"
        fi
    else
        echo "Item not found: $name"
        return 1
    fi
}

# Get username
function bw-username() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    bw get username "$name" 2>/dev/null
}

# Get TOTP code
function bw-totp() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local totp=$(bw get totp "$name" 2>/dev/null)
    
    if [[ -n "$totp" ]]; then
        if command -v wl-copy &>/dev/null; then
            echo -n "$totp" | wl-copy
            echo "TOTP for '$name': $totp (copied)"
        else
            echo "$totp"
        fi
    else
        echo "TOTP not found for: $name"
        return 1
    fi
}

# Get item details
function bw-item() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    bw get item "$name" 2>/dev/null | jq '.'
}

# List all items
function bw-list() {
    bw-ensure-unlocked || return 1
    
    bw list items 2>/dev/null | \
        jq -r '.[] | "\(.name)\t\(.login.username // "N/A")\t\(.login.uris[0].uri // "N/A")"' | \
        column -t -s $'\t'
}

# List folders
function bw-folders() {
    bw-ensure-unlocked || return 1
    
    bw list folders 2>/dev/null | jq -r '.[].name'
}

# List items in folder
function bw-folder() {
    bw-ensure-unlocked || return 1
    
    local folder="$1"
    local folder_id=$(bw list folders 2>/dev/null | \
        jq -r ".[] | select(.name == \"$folder\") | .id")
    
    if [[ -n "$folder_id" ]]; then
        bw list items --folderid "$folder_id" 2>/dev/null | \
            jq -r '.[].name'
    else
        echo "Folder not found: $folder"
        return 1
    fi
}

#=============================================================================
# PASSWORD GENERATION
#=============================================================================

# Generate password
function bw-generate() {
    local length="${1:-20}"
    local options="${2:--ulns}"  # uppercase, lowercase, number, special
    
    bw generate -${options} --length "$length"
}

# Generate and copy
function bw-gencopy() {
    local password=$(bw-generate "$@")
    
    if command -v wl-copy &>/dev/null; then
        echo -n "$password" | wl-copy
        echo "Generated and copied: $password"
    else
        echo "$password"
    fi
}

# Generate passphrase
function bw-passphrase() {
    local words="${1:-4}"
    local separator="${2:--}"
    
    bw generate --passphrase --words "$words" --separator "$separator"
}

#=============================================================================
# CREATE/MODIFY ITEMS
#=============================================================================

# Quick create login item
function bw-create-login() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local username="$2"
    local uri="$3"
    
    if [[ -z "$name" || -z "$username" ]]; then
        # echo "Usage: bw-create-login <name> <username> [uri]"
        return 1
    fi
    
    read -s "password?Password (empty to generate): "
    echo
    
    if [[ -z "$password" ]]; then
        password=$(bw-generate)
        echo "Generated password: $password"
    fi
    
    local template=$(bw get template item)
    local item=$(echo "$template" | jq --arg name "$name" \
        --arg username "$username" \
        --arg password "$password" \
        --arg uri "$uri" \
        '.name = $name | .type = 1 | .login = {username: $username, password: $password, uris: [{uri: $uri}]}')
    
    echo "$item" | bw encode | bw create item
    echo "Created item: $name"
}

# Delete item
function bw-delete() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local id=$(bw get item "$name" 2>/dev/null | jq -r '.id')
    
    if [[ -n "$id" ]]; then
        read -q "?Delete '$name'? [y/N] "
        echo
        if [[ $REPLY == "y" ]]; then
            bw delete item "$id"
            echo "Deleted: $name"
        fi
    else
        echo "Item not found: $name"
        return 1
    fi
}

#=============================================================================
# SYNC
#=============================================================================

function bw-sync() {
    bw-ensure-unlocked || return 1
    bw sync
    echo "Vault synced"
}

#=============================================================================
# SSH KEY INTEGRATION
# Retrieve SSH keys stored in Bitwarden
#=============================================================================

# Get SSH key from secure note
function bw-ssh-key() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local key=$(bw get item "$name" 2>/dev/null | jq -r '.notes')
    
    if [[ -n "$key" && "$key" != "null" ]]; then
        echo "$key"
    else
        echo "SSH key not found: $name"
        return 1
    fi
}

# Add SSH key to agent from Bitwarden
function bw-ssh-add() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local key=$(bw-ssh-key "$name")
    
    if [[ -n "$key" ]]; then
        local tmp=$(mktemp)
        echo "$key" > "$tmp"
        chmod 600 "$tmp"
        ssh-add "$tmp"
        rm -f "$tmp"
        echo "Added SSH key: $name"
    fi
}

#=============================================================================
# ENV/SECRETS INTEGRATION
# Load environment variables from Bitwarden
#=============================================================================

# Export env vars from a secure note
function bw-env() {
    bw-ensure-unlocked || return 1
    
    local name="$1"
    local notes=$(bw get item "$name" 2>/dev/null | jq -r '.notes')
    
    if [[ -n "$notes" && "$notes" != "null" ]]; then
        eval "$notes"
        echo "Environment loaded from: $name"
    else
        echo "Env not found: $name"
        return 1
    fi
}

#=============================================================================
# FZF INTEGRATIONS
#=============================================================================

# Interactive item browser
function bw-fzf() {
    bw-ensure-unlocked || return 1
    
    local action
    action=$(echo -e "Get Password\nGet Username\nGet TOTP\nView Item\nCopy URI" | \
        fzf --header '╭─ Action ─╮')
    
    [[ -z "$action" ]] && return
    
    local item
    item=$(bw list items 2>/dev/null | \
        jq -r '.[] | "\(.name)\t\(.id)"' | \
        fzf --with-nth 1 --delimiter '\t' \
            --header '╭─ Select Item ─╮')
    
    [[ -z "$item" ]] && return
    
    local id=$(echo "$item" | cut -f2)
    
    case "$action" in
        "Get Password")
            local pass=$(bw get password "$id" 2>/dev/null)
            echo -n "$pass" | wl-copy 2>/dev/null
            echo "Password copied"
            ;;
        "Get Username")
            local user=$(bw get username "$id" 2>/dev/null)
            echo -n "$user" | wl-copy 2>/dev/null
            echo "Username: $user (copied)"
            ;;
        "Get TOTP")
            local totp=$(bw get totp "$id" 2>/dev/null)
            echo -n "$totp" | wl-copy 2>/dev/null
            echo "TOTP: $totp (copied)"
            ;;
        "View Item")
            bw get item "$id" 2>/dev/null | jq '.'
            ;;
        "Copy URI")
            local uri=$(bw get item "$id" 2>/dev/null | jq -r '.login.uris[0].uri')
            echo -n "$uri" | wl-copy 2>/dev/null
            echo "URI: $uri (copied)"
            ;;
    esac
}

#=============================================================================
# ALIASES
#=============================================================================
alias bws='bw-status'
alias bwu='bw-unlock'
alias bwl='bw-lock'
alias bwg='bw-get'
alias bwp='bw-password'
alias bwt='bw-totp'
alias bwgen='bw-generate'
alias bwsync='bw-sync'
alias bwf='bw-fzf'
