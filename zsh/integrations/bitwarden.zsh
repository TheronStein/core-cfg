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

# Unlock vault (with keyring persistence)
function bw-unlock() {
    # Try keyring first
    local session
    session="$(secret-tool lookup bw session 2>/dev/null)"

    if [[ -n "$session" ]]; then
        export BW_SESSION="$session"
        # Verify session is still valid
        if bw unlock --check >/dev/null 2>&1; then
            echo "Vault session loaded from keyring"
            return 0
        fi
    fi

    # Session expired or missing - need to unlock
    BW_SESSION=$(bw unlock --raw 2>/dev/null)
    export BW_SESSION

    if [[ -n "$BW_SESSION" ]]; then
        # Save to keyring for other terminals
        echo "$BW_SESSION" | secret-tool store --label="Bitwarden Session" bw session
        echo "Vault unlocked and saved to keyring"
    else
        echo "Unlock failed"
        return 1
    fi
}

# Lock vault (clears keyring)
function bw-lock() {
    bw lock
    secret-tool clear bw session 2>/dev/null
    unset BW_SESSION
    echo "Vault locked and session cleared"
}

# Logout
function bw-logout() {
    bw logout
    unset BW_SESSION
    echo "Logged out"
}

# Auto-unlock wrapper
function bw-ensure-unlocked() {
    local bw_status=$(bw status 2>/dev/null | jq -r '.status')

    case "$bw_status" in
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
            echo "Unknown status: $bw_status"
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

# Wrapper function for ~/.zshrc
bw-once() {
  bw get password "$1" | wl-copy
  echo "Password copied - clearing after first paste"
  wl-paste-watch --one-shot wl-copy --clear
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


# Check if Bitwarden session is active
_bw_check_session() {
  if ! bw unlock --check &>/dev/null; then
    echo "❌ Bitwarden vault locked. Run: bw unlock"
    return 1
  fi
  return 0
}

# Check if fzf is available
_bw_has_fzf() {
  command -v fzf &>/dev/null
}

# List all folders in vault with fzf selection
bw-folders() {
  _bw_check_session || return 1
  
  local folders=$(bw list folders | jq -r '.[] | "\(.id)|\(.name)"')
  local no_folder=$(bw list items --folderid null | jq 'length')
  
  if _bw_has_fzf && [[ "$1" == "-s" ]]; then
    # Interactive selection mode
    local selected=$(echo "$folders" | column -t -s '|' | \
      fzf --header="Select a folder (ESC to cancel)" \
          --preview='echo {}' \
          --preview-window=up:3:wrap)
    
    if [[ -n "$selected" ]]; then
      echo "$selected" | awk '{print $1}'
      return 0
    fi
    return 1
  else
    # Display mode
    echo "📁 Bitwarden Folders:"
    echo "─────────────────────"
    echo "$folders" | column -t -s '|'
    echo "─────────────────────"
    echo "Items without folder: $no_folder"
    echo ""
    echo "Tip: Use 'bw-folders -s' for interactive selection"
  fi
}

# List all items in a specific folder with fzf selection
bw-list() {
  _bw_check_session || return 1
  
  local folder_name="$1"
  
  # If no folder specified and fzf available, let user select
  if [[ -z "$folder_name" ]] && _bw_has_fzf; then
    local folders=$(bw list folders | jq -r '.[] | "\(.name)|\(.id)"')
    folder_name=$(echo "$folders" | \
      fzf --header="Select folder to list items" \
          --delimiter='|' \
          --with-nth=1 \
          --preview='bw list items --folderid {2} | jq -r ".[].name"' \
          --preview-window=right:50%:wrap | \
      cut -d'|' -f1)
    
    if [[ -z "$folder_name" ]]; then
      echo "No folder selected"
      return 1
    fi
  elif [[ -z "$folder_name" ]]; then
    echo "Usage: bw-list <folder-name>"
    echo "Tip: Use 'bw-folders' to see available folders"
    return 1
  fi
  
  local folder_id=$(bw list folders | jq -r ".[] | select(.name==\"$folder_name\") | .id")
  
  if [[ -z "$folder_id" ]]; then
    echo "❌ Folder not found: $folder_name"
    return 1
  fi
  
  local items=$(bw list items --folderid "$folder_id" | \
    jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
  
  if _bw_has_fzf && [[ "$2" == "-s" ]]; then
    # Interactive selection mode
    local selected=$(echo "$items" | column -t -s '|' | \
      fzf --header="Items in: $folder_name (ESC to cancel)" \
          --preview='echo {}' \
          --preview-window=up:3:wrap)
    
    if [[ -n "$selected" ]]; then
      echo "$selected" | awk '{print $1}'
      return 0
    fi
    return 1
  else
    echo "📋 Items in folder: $folder_name"
    echo "─────────────────────────────────────"
    echo "$items" | column -t -s '|'
    echo ""
    echo "Tip: Use 'bw-list \"$folder_name\" -s' for interactive selection"
  fi
}

# List items without a folder
bw-list-unfiled() {
  _bw_check_session || return 1
  
  local items=$(bw list items --folderid null | \
    jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
  
  if _bw_has_fzf && [[ "$1" == "-s" ]]; then
    local selected=$(echo "$items" | column -t -s '|' | \
      fzf --header="Unfiled items (ESC to cancel)" \
          --preview='echo {}' \
          --preview-window=up:3:wrap)
    
    if [[ -n "$selected" ]]; then
      echo "$selected" | awk '{print $1}'
      return 0
    fi
    return 1
  else
    echo "📋 Items without folder:"
    echo "─────────────────────────────────────"
    echo "$items" | column -t -s '|'
    echo ""
    echo "Tip: Use 'bw-list-unfiled -s' for interactive selection"
  fi
}

# Search for items with fzf
bw-search() {
  _bw_check_session || return 1
  
  if ! _bw_has_fzf; then
    if [[ -z "$1" ]]; then
      echo "Usage: bw-search <search-term>"
      return 1
    fi
    
    echo "🔍 Searching for: $1"
    echo "─────────────────────────────────────"
    bw list items --search "$1" | \
      jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")|Folder: \(.folderId // "none")"' | \
      column -t -s '|'
    return 0
  fi
  
  # Interactive fuzzy search
  local all_items=$(bw list items | \
    jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")|\(.folderId // "none")"')
  
  local selected=$(echo "$all_items" | \
    fzf --header="Search all items (type to filter)" \
        --delimiter='|' \
        --with-nth=2,3 \
        --preview='bw get item {1} | jq -r "{name, username: .login.username, url: .login.uris[0].uri, folder: .folderId}"' \
        --preview-window=right:50%:wrap)
  
  if [[ -n "$selected" ]]; then
    local item_id=$(echo "$selected" | cut -d'|' -f1)
    local item_name=$(echo "$selected" | cut -d'|' -f2)
    echo "Selected: $item_name"
    echo "ID: $item_id"
    return 0
  fi
  return 1
}

# Create a new folder
bw-folder-create() {
  _bw_check_session || return 1
  
  if [[ -z "$1" ]]; then
    echo "Usage: bw-folder-create <folder-name>"
    return 1
  fi
  
  local folder_name="$1"
  
  local existing=$(bw list folders | jq -r ".[] | select(.name==\"$folder_name\") | .id")
  if [[ -n "$existing" ]]; then
    echo "❌ Folder already exists: $folder_name"
    return 1
  fi
  
  echo "{\"name\":\"$folder_name\"}" | bw encode | bw create folder
  
  if [[ $? -eq 0 ]]; then
    echo "✓ Created folder: $folder_name"
    bw sync
  else
    echo "❌ Failed to create folder"
    return 1
  fi
}

# Rename a folder with fzf selection
bw-folder-rename() {
  _bw_check_session || return 1
  
  local old_name="$1"
  local new_name="$2"
  
  # If no folder specified and fzf available, let user select
  if [[ -z "$old_name" ]] && _bw_has_fzf; then
    local folders=$(bw list folders | jq -r '.[] | "\(.id)|\(.name)"')
    old_name=$(echo "$folders" | \
      fzf --header="Select folder to rename" \
          --delimiter='|' \
          --with-nth=2 \
          --preview='bw list items --folderid {1} | jq -r "length as $count | \"Items in folder: \\($count)\""' \
          --preview-window=up:3:wrap | \
      cut -d'|' -f2)
    
    if [[ -z "$old_name" ]]; then
      echo "No folder selected"
      return 1
    fi
    
    read "new_name?Enter new name for '$old_name': "
  fi
  
  if [[ -z "$old_name" ]] || [[ -z "$new_name" ]]; then
    echo "Usage: bw-folder-rename <old-name> <new-name>"
    return 1
  fi
  
  local folder_id=$(bw list folders | jq -r ".[] | select(.name==\"$old_name\") | .id")
  
  if [[ -z "$folder_id" ]]; then
    echo "❌ Folder not found: $old_name"
    return 1
  fi
  
  bw get folder "$folder_id" | \
    jq ".name = \"$new_name\"" | \
    bw encode | \
    bw edit folder "$folder_id"
  
  if [[ $? -eq 0 ]]; then
    echo "✓ Renamed folder: $old_name → $new_name"
    bw sync
  else
    echo "❌ Failed to rename folder"
    return 1
  fi
}

# Move a single item to a folder with fzf selection
bw-move() {
  _bw_check_session || return 1
  
  local item_query="$1"
  local folder_name="$2"
  
  # If no item specified and fzf available, let user select
  if [[ -z "$item_query" ]] && _bw_has_fzf; then
    local all_items=$(bw list items | \
      jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
    
    local selected_item=$(echo "$all_items" | \
      fzf --header="Select item to move" \
          --delimiter='|' \
          --with-nth=2,3 \
          --preview='bw get item {1} | jq -r "{name, username: .login.username, folder: .folderId}"' \
          --preview-window=right:40%:wrap)
    
    if [[ -z "$selected_item" ]]; then
      echo "No item selected"
      return 1
    fi
    
    item_query=$(echo "$selected_item" | cut -d'|' -f1)
  fi
  
  # If no folder specified and fzf available, let user select
  if [[ -z "$folder_name" ]] && _bw_has_fzf; then
    local folders=$(bw list folders | jq -r '.[] | "\(.id)|\(.name)"')
    folder_name=$(echo "$folders" | \
      fzf --header="Select destination folder" \
          --delimiter='|' \
          --with-nth=2 \
          --preview='bw list items --folderid {1} | jq -r ".[].name"' \
          --preview-window=right:40%:wrap | \
      cut -d'|' -f2)
    
    if [[ -z "$folder_name" ]]; then
      echo "No folder selected"
      return 1
    fi
  fi
  
  if [[ -z "$item_query" ]] || [[ -z "$folder_name" ]]; then
    echo "Usage: bw-move <item-name-or-id> <folder-name>"
    return 1
  fi
  
  local folder_id=$(bw list folders | jq -r ".[] | select(.name==\"$folder_name\") | .id")
  
  if [[ -z "$folder_id" ]]; then
    echo "❌ Folder not found: $folder_name"
    return 1
  fi
  
  local item=$(bw get item "$item_query" 2>/dev/null)
  if [[ -z "$item" ]]; then
    item=$(bw list items --search "$item_query" | jq '.[0]')
  fi
  
  if [[ -z "$item" ]] || [[ "$item" == "null" ]]; then
    echo "❌ Item not found: $item_query"
    return 1
  fi
  
  local item_id=$(echo "$item" | jq -r '.id')
  local item_name=$(echo "$item" | jq -r '.name')
  
  echo "$item" | \
    jq ".folderId = \"$folder_id\"" | \
    bw encode | \
    bw edit item "$item_id"
  
  if [[ $? -eq 0 ]]; then
    echo "✓ Moved '$item_name' → $folder_name"
    bw sync
  else
    echo "❌ Failed to move item"
    return 1
  fi
}

# Move multiple items to a folder with fzf multi-select
bw-move-batch() {
  _bw_check_session || return 1
  
  if ! _bw_has_fzf; then
    echo "❌ fzf is required for batch operations"
    return 1
  fi
  
  local folder_name="$1"
  
  # Multi-select items
  local all_items=$(bw list items | \
    jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")|\(.folderId // "none")"')
  
  local selected_items=$(echo "$all_items" | \
    fzf --multi \
        --header="Select items to move (TAB to select multiple, ENTER to confirm)" \
        --delimiter='|' \
        --with-nth=2,3 \
        --preview='bw get item {1} | jq -r "{name, username: .login.username, current_folder: .folderId}"' \
        --preview-window=right:40%:wrap)
  
  if [[ -z "$selected_items" ]]; then
    echo "No items selected"
    return 1
  fi
  
  # Select destination folder
  if [[ -z "$folder_name" ]]; then
    local folders=$(bw list folders | jq -r '.[] | "\(.id)|\(.name)"')
    folder_name=$(echo "$folders" | \
      fzf --header="Select destination folder" \
          --delimiter='|' \
          --with-nth=2 \
          --preview='bw list items --folderid {1} | jq -r ".[].name"' \
          --preview-window=right:40%:wrap | \
      cut -d'|' -f2)
    
    if [[ -z "$folder_name" ]]; then
      echo "No folder selected"
      return 1
    fi
  fi
  
  local folder_id=$(bw list folders | jq -r ".[] | select(.name==\"$folder_name\") | .id")
  
  if [[ -z "$folder_id" ]]; then
    echo "❌ Folder not found: $folder_name"
    return 1
  fi
  
  local count=$(echo "$selected_items" | wc -l)
  echo "Moving $count items to '$folder_name':"
  echo "$selected_items" | cut -d'|' -f2 | sed 's/^/  - /'
  echo ""
  read -q "REPLY?Continue? (y/n) "
  echo ""
  
  if [[ "$REPLY" != "y" ]]; then
    echo "Cancelled"
    return 0
  fi
  
  local success=0
  local failed=0
  
  echo "$selected_items" | while IFS='|' read -r item_id item_name rest; do
    local item=$(bw get item "$item_id")
    
    echo "$item" | \
      jq ".folderId = \"$folder_id\"" | \
      bw encode | \
      bw edit item "$item_id" > /dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
      echo "  ✓ $item_name"
      ((success++))
    else
      echo "  ❌ $item_name"
      ((failed++))
    fi
  done
  
  echo ""
  echo "Moved: $success | Failed: $failed"
  bw sync
}

# Copy password to clipboard with fzf selection
bw-once() {
  _bw_check_session || return 1
  
  local item_query="$1"
  
  # If no item specified and fzf available, let user select
  if [[ -z "$item_query" ]] && _bw_has_fzf; then
    local all_items=$(bw list items | \
      jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
    
    item_query=$(echo "$all_items" | \
      fzf --header="Select item to copy password" \
          --delimiter='|' \
          --with-nth=2,3 \
          --preview='bw get item {1} | jq -r "{name, username: .login.username, url: .login.uris[0].uri}"' \
          --preview-window=right:40%:wrap | \
      cut -d'|' -f1)
    
    if [[ -z "$item_query" ]]; then
      echo "No item selected"
      return 1
    fi
  fi
  
  if [[ -z "$item_query" ]]; then
    echo "Usage: bw-once <item-name>"
    return 1
  fi
  
  local pass=$(bw get password "$item_query" 2>/dev/null)
  
  if [[ -z "$pass" ]]; then
    echo "❌ Item not found: $item_query"
    return 1
  fi
  
  echo "$pass" | wl-copy
  echo "✓ Password copied - will clear after first paste"
  wl-paste-watch --one-shot wl-copy --clear
}

# Show item details with fzf selection
bw-show() {
  _bw_check_session || return 1
  
  local item_query="$1"
  
  # If no item specified and fzf available, let user select
  if [[ -z "$item_query" ]] && _bw_has_fzf; then
    local all_items=$(bw list items | \
      jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
    
    item_query=$(echo "$all_items" | \
      fzf --header="Select item to view details" \
          --delimiter='|' \
          --with-nth=2,3 \
          --preview='bw get item {1} | jq -r "{name, username: .login.username, url: .login.uris[0].uri, notes: .notes}"' \
          --preview-window=right:50%:wrap | \
      cut -d'|' -f1)
    
    if [[ -z "$item_query" ]]; then
      echo "No item selected"
      return 1
    fi
  fi
  
  if [[ -z "$item_query" ]]; then
    echo "Usage: bw-show <item-name-or-id>"
    return 1
  fi
  
  bw get item "$item_query" 2>/dev/null | jq '{
    name: .name,
    username: .login.username,
    folder: .folderId,
    urls: .login.uris[].uri,
    notes: .notes
  }'
}

# Interactive browser - navigate folders and items
bw-browse() {
  _bw_check_session || return 1
  
  if ! _bw_has_fzf; then
    echo "❌ fzf is required for interactive browsing"
    return 1
  fi
  
  while true; do
    local folders=$(bw list folders | jq -r '.[] | "📁 \(.name)|\(.id)"')
    local unfiled_count=$(bw list items --folderid null | jq 'length')
    local options="📁 [Unfiled Items] ($unfiled_count)|unfiled
$folders
🔍 Search all items|search
❌ Exit|exit"
    
    local selected=$(echo "$options" | \
      fzf --header="Bitwarden Browser - Select a folder or action" \
          --delimiter='|' \
          --with-nth=1 \
          --preview='[[ {2} == "unfiled" ]] && bw list items --folderid null | jq -r ".[].name" || [[ {2} == "search" ]] && echo "Search through all items" || [[ {2} == "exit" ]] && echo "Exit browser" || bw list items --folderid {2} | jq -r ".[].name"' \
          --preview-window=right:50%:wrap)
    
    if [[ -z "$selected" ]]; then
      break
    fi
    
    local action=$(echo "$selected" | cut -d'|' -f2)
    
    case "$action" in
      exit)
        break
        ;;
      search)
        bw-search
        ;;
      unfiled)
        local items=$(bw list items --folderid null | \
          jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
        
        local selected_item=$(echo "$items" | \
          fzf --header="Unfiled Items - Select an item" \
              --delimiter='|' \
              --with-nth=2,3 \
              --preview='bw get item {1} | jq' \
              --preview-window=right:50%:wrap)
        
        if [[ -n "$selected_item" ]]; then
          local item_id=$(echo "$selected_item" | cut -d'|' -f1)
          echo ""
          echo "Actions: [c]opy password | [s]how details | [m]ove to folder | [b]ack"
          read -k 1 action_key
          echo ""
          
          case "$action_key" in
            c)
              bw get password "$item_id" | wl-copy
              echo "✓ Password copied"
              wl-paste-watch --one-shot wl-copy --clear
              ;;
            s)
              bw-show "$item_id"
              read -k 1 "?Press any key to continue..."
              ;;
            m)
              bw-move "$item_id"
              ;;
          esac
        fi
        ;;
      *)
        local folder_id="$action"
        local folder_name=$(echo "$selected" | cut -d'|' -f1 | sed 's/📁 //')
        
        local items=$(bw list items --folderid "$folder_id" | \
          jq -r '.[] | "\(.id)|\(.name)|\(.login.username // "no username")"')
        
        local selected_item=$(echo "$items" | \
          fzf --header="$folder_name - Select an item" \
              --delimiter='|' \
              --with-nth=2,3 \
              --preview='bw get item {1} | jq' \
              --preview-window=right:50%:wrap)
        
        if [[ -n "$selected_item" ]]; then
          local item_id=$(echo "$selected_item" | cut -d'|' -f1)
          echo ""
          echo "Actions: [c]opy password | [s]how details | [m]ove to folder | [b]ack"
          read -k 1 action_key
          echo ""
          
          case "$action_key" in
            c)
              bw get password "$item_id" | wl-copy
              echo "✓ Password copied"
              wl-paste-watch --one-shot wl-copy --clear
              ;;
            s)
              bw-show "$item_id"
              read -k 1 "?Press any key to continue..."
              ;;
            m)
              bw-move "$item_id"
              ;;
          esac
        fi
        ;;
    esac
  done
}

# Completion helper - list folder names
_bw_folders_completion() {
  _bw_check_session || return
  local folders=($(bw list folders 2>/dev/null | jq -r '.[].name'))
  _describe 'folders' folders
}

# Completion helper - list item names
_bw_items_completion() {
  _bw_check_session || return
  local items=($(bw list items 2>/dev/null | jq -r '.[].name'))
  _describe 'items' items
}

# Setup completions if using zsh
if [[ -n "$ZSH_VERSION" ]]; then
  compdef _bw_folders_completion bw-list bw-folder-rename
  compdef _bw_items_completion bw-once bw-show bw-move
fi

#=============================================================================
# GITHUB CLI INTEGRATION
#=============================================================================

# Refresh gh auth from Bitwarden-stored token
function gh-auth-refresh() {
    bw-ensure-unlocked || return 1
    bw get notes "GitHub Personal Access Token" 2>/dev/null | gh auth login --with-token
    if [[ $? -eq 0 ]]; then
        echo "GitHub CLI authenticated from Bitwarden"
    else
        echo "Failed to authenticate GitHub CLI"
        return 1
    fi
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
alias ghar='gh-auth-refresh'
