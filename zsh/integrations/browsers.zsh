# ~/.core/zsh/integrations/browsers.zsh
# Unified Browser Framework - Modular fzf-based browser system
#
# This file provides a comprehensive framework for creating interactive browsers
# (theme selectors, cheatsheets, keymaps, etc.) with consistent styling and behavior.
#
# Architecture:
#   - Data stored in $ZDOTDIR/.data/ (git-backed, version controlled)
#   - Unified fzf theme via _fzf_base_opts() from integrations/fzf.zsh
#   - Template-based system for easy addition of new browsers
#   - Multi-layer integration: shell, tmux, wezterm, CLI
#
# Dependencies: fzf, jq (optional for JSON data)

#=============================================================================
# CORE FRAMEWORK - DATA MANAGEMENT
#=============================================================================

# Global configuration
typeset -g BROWSER_DATA_DIR="${ZDOTDIR}/.data"
typeset -g BROWSER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/browsers"

# Ensure directories exist
[[ ! -d "$BROWSER_DATA_DIR" ]] && mkdir -p "$BROWSER_DATA_DIR"
[[ ! -d "$BROWSER_CACHE_DIR" ]] && mkdir -p "$BROWSER_CACHE_DIR"

# Function: data::ensure
# Description: Ensures data file exists, generates if missing
# Usage: data::ensure BROWSER_NAME
# Returns: 0 if data exists or was generated, 1 on error
data::ensure() {
  local browser_name="$1"
  local data_file="$2"
  local generator_func="data::generate::${browser_name}"

  # Check if data file exists
  if [[ ! -f "$data_file" ]]; then
    # Check if generator function exists
    if (( $+functions[$generator_func] )); then
      echo "Generating data for ${browser_name}..." >&2
      $generator_func || {
        echo "Error: Failed to generate data for ${browser_name}" >&2
        return 1
      }
    else
      echo "Error: No data file and no generator for ${browser_name}" >&2
      echo "Expected: $data_file or function ${generator_func}" >&2
      return 1
    fi
  fi

  return 0
}

# Function: data::load
# Description: Loads data from file with optional jq filter
# Usage: data::load FILE [JQ_FILTER]
# Returns: Data content
data::load() {
  local file="$1"
  local filter="${2:-.}"

  if [[ ! -f "$file" ]]; then
    echo "Error: Data file not found: $file" >&2
    return 1
  fi

  # If jq available and filter provided, use it
  if (( $+commands[jq] )) && [[ "$filter" != "." ]]; then
    jq -r "$filter" "$file"
  else
    cat "$file"
  fi
}

# Function: data::cache
# Description: Cache expensive operations
# Usage: data::cache CACHE_NAME GENERATOR_COMMAND
# Returns: Cached or freshly generated content
data::cache() {
  local cache_name="$1"
  shift
  local cache_file="$BROWSER_CACHE_DIR/${cache_name}.cache"
  local max_age=3600  # 1 hour

  # Check if cache exists and is fresh
  if [[ -f "$cache_file" ]]; then
    local age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file") ))
    if (( age < max_age )); then
      cat "$cache_file"
      return 0
    fi
  fi

  # Generate fresh data and cache it
  "$@" | tee "$cache_file"
}

#=============================================================================
# CORE FRAMEWORK - BROWSER HELPERS
#=============================================================================

# Function: browser::base
# Description: Base browser implementation with standard behavior
# Usage: browser::base BROWSER_NAME DATA_LOADER PREVIEW_CMD [HEADER] [ACTION_HANDLER]
# This is the core browser engine that handles the common patterns
browser::base() {
  local browser_name="$1"
  local data_loader="$2"
  local preview_cmd="$3"
  local header="${4:-Select an item}"
  local action_handler="${5:-}"
  local border_label="${6:-}"

  local selection

  # Build fzf command
  local fzf_cmd="fzf $(_fzf_base_opts) --height=100% --prompt=\"${browser_name} ❯ \" --header=\"$header\" --preview=\"$preview_cmd\" --preview-window=right:60%:wrap:rounded"

  # Add border label if provided
  [[ -n "$border_label" ]] && fzf_cmd="$fzf_cmd --border-label=\"$border_label\""

  # Run fzf with unified theme
  selection=$($data_loader | eval "$fzf_cmd")

  # Handle selection
  [[ -z "$selection" ]] && return 0

  # If action handler provided, use it
  if [[ -n "$action_handler" ]] && (( $+functions[$action_handler] )); then
    $action_handler "$selection"
  else
    # Default action: echo selection
    echo "$selection"
  fi
}

# Function: browser::multi
# Description: Multi-select browser with batch actions
# Usage: browser::multi BROWSER_NAME DATA_LOADER PREVIEW_CMD [HEADER] [ACTION_HANDLER]
browser::multi() {
  local browser_name="$1"
  local data_loader="$2"
  local preview_cmd="$3"
  local header="${4:-Select items (Tab to multi-select)}"
  local action_handler="${5:-}"

  local selections

  # Run fzf with multi-select
  selections=$($data_loader | \
    fzf $(_fzf_base_opts) \
      --height=100% \
      --multi \
      --prompt="${browser_name} ❯ " \
      --header="$header" \
      --preview="$preview_cmd" \
      --preview-window='right:60%:wrap' \
      --bind='ctrl-a:select-all,ctrl-d:deselect-all')

  # Handle selections
  [[ -z "$selections" ]] && return 0

  # If action handler provided, use it
  if [[ -n "$action_handler" ]] && (( $+functions[$action_handler] )); then
    echo "$selections" | while IFS= read -r item; do
      $action_handler "$item"
    done
  else
    # Default action: echo selections
    echo "$selections"
  fi
}

# Function: browser::widget
# Description: Wrapper to make any browser work as a ZLE widget
# Usage: browser::widget BROWSER_FUNCTION [INSERT_MODE]
# INSERT_MODE: 'insert' to insert result, 'execute' to execute, 'none' for side effects
browser::widget() {
  local browser_func="$1"
  local insert_mode="${2:-insert}"

  local result
  result=$($browser_func)

  case "$insert_mode" in
    insert)
      [[ -n "$result" ]] && LBUFFER+="$result"
      ;;
    execute)
      [[ -n "$result" ]] && BUFFER="$result" && zle accept-line
      ;;
    none)
      # Browser had side effects, just reset prompt
      ;;
  esac

  zle reset-prompt
}

#=============================================================================
# BROWSER: CHEATSHEETS
#=============================================================================

# Data generator for cheatsheets
data::generate::cheatsheets() {
  local cheat_dir="$BROWSER_DATA_DIR/cheatsheets"
  mkdir -p "$cheat_dir"

  # Generate Git cheatsheet
  cat > "$cheat_dir/git.txt" <<'EOF'
# Git Cheatsheet
# Common git commands with explanations

## Basics
git init                    # Initialize new repository
git clone <url>             # Clone remote repository
git status                  # Show working tree status
git add <file>              # Stage file for commit
git add .                   # Stage all changes
git commit -m "message"     # Commit staged changes
git commit --amend          # Amend last commit

## Branching
git branch                  # List branches
git branch <name>           # Create new branch
git checkout <branch>       # Switch to branch
git checkout -b <branch>    # Create and switch to new branch
git switch <branch>         # Switch to branch (newer syntax)
git switch -c <branch>      # Create and switch (newer syntax)
git merge <branch>          # Merge branch into current
git branch -d <branch>      # Delete branch

## Remote Operations
git remote -v               # List remotes
git remote add <name> <url> # Add remote
git fetch <remote>          # Fetch from remote
git pull                    # Fetch and merge
git push                    # Push to remote
git push -u origin <branch> # Push and set upstream

## History & Inspection
git log                     # Show commit history
git log --oneline           # Compact log
git log --graph --oneline   # Graph view
git show <commit>           # Show commit details
git diff                    # Show unstaged changes
git diff --staged           # Show staged changes
git diff <branch1> <branch2> # Compare branches

## Stashing
git stash                   # Stash changes
git stash list              # List stashes
git stash pop               # Apply and remove latest stash
git stash apply             # Apply latest stash (keep it)
git stash drop              # Remove latest stash

## Undoing Changes
git reset <file>            # Unstage file
git reset --soft HEAD~1     # Undo last commit (keep changes staged)
git reset --hard HEAD~1     # Undo last commit (discard changes)
git revert <commit>         # Create new commit undoing changes
git checkout -- <file>      # Discard changes in file
git restore <file>          # Restore file (newer syntax)

## Worktrees
git worktree add <path> <branch>  # Create worktree
git worktree list                  # List worktrees
git worktree remove <path>         # Remove worktree

## Tags
git tag                     # List tags
git tag <name>              # Create tag
git tag -a <name> -m "msg"  # Create annotated tag
git push --tags             # Push tags to remote

## Configuration
git config --global user.name "Name"      # Set username
git config --global user.email "email"    # Set email
git config --list                         # List configuration
EOF

  # Generate Docker cheatsheet
  cat > "$cheat_dir/docker.txt" <<'EOF'
# Docker Cheatsheet
# Common docker commands

## Container Management
docker ps                   # List running containers
docker ps -a                # List all containers
docker run <image>          # Run container
docker run -d <image>       # Run in detached mode
docker run -it <image> bash # Run interactive with bash
docker start <container>    # Start stopped container
docker stop <container>     # Stop container
docker restart <container>  # Restart container
docker rm <container>       # Remove container
docker rm $(docker ps -aq)  # Remove all containers

## Image Management
docker images               # List images
docker pull <image>         # Pull image
docker build -t <name> .    # Build image from Dockerfile
docker tag <image> <tag>    # Tag image
docker rmi <image>          # Remove image
docker image prune          # Remove dangling images

## Container Inspection
docker logs <container>     # View logs
docker logs -f <container>  # Follow logs
docker inspect <container>  # Inspect container
docker stats                # Show resource usage
docker top <container>      # Show running processes

## Execution
docker exec <container> <cmd>     # Execute command
docker exec -it <container> bash  # Interactive bash shell
docker attach <container>         # Attach to container

## Networks
docker network ls           # List networks
docker network create <name> # Create network
docker network inspect <network> # Inspect network

## Volumes
docker volume ls            # List volumes
docker volume create <name> # Create volume
docker volume inspect <vol> # Inspect volume
docker volume rm <vol>      # Remove volume

## Docker Compose
docker compose up           # Start services
docker compose up -d        # Start in detached mode
docker compose down         # Stop and remove services
docker compose ps           # List services
docker compose logs         # View logs
docker compose exec <svc> <cmd> # Execute command in service

## Cleanup
docker system prune         # Remove unused data
docker system prune -a      # Remove all unused data
docker container prune      # Remove stopped containers
docker image prune          # Remove dangling images
docker volume prune         # Remove unused volumes
EOF

  # Generate Tmux cheatsheet
  cat > "$cheat_dir/tmux.txt" <<'EOF'
# Tmux Cheatsheet
# Prefix key: Ctrl+b (default) or Super+Space (custom)

## Session Management
tmux                        # Start new session
tmux new -s <name>          # Start named session
tmux ls                     # List sessions
tmux attach -t <session>    # Attach to session
tmux kill-session -t <name> # Kill session
Prefix d                    # Detach from session
Prefix $                    # Rename session
Prefix s                    # Session picker

## Window Management
Prefix c                    # Create new window
Prefix ,                    # Rename window
Prefix n                    # Next window
Prefix p                    # Previous window
Prefix <number>             # Switch to window number
Prefix w                    # Window picker
Prefix &                    # Kill window

## Pane Management
Prefix %                    # Split horizontally
Prefix "                    # Split vertically
Prefix o                    # Next pane
Prefix arrow                # Switch pane (arrow keys)
Prefix z                    # Zoom pane (toggle)
Prefix x                    # Kill pane
Prefix {                    # Move pane left
Prefix }                    # Move pane right
Prefix Space                # Cycle layouts
Prefix Ctrl+arrow           # Resize pane

## Copy Mode
Prefix [                    # Enter copy mode
q                           # Exit copy mode
Space                       # Start selection
Enter                       # Copy selection
Prefix ]                    # Paste buffer

## Miscellaneous
Prefix ?                    # List key bindings
Prefix :                    # Command prompt
Prefix t                    # Show time
Prefix r                    # Reload config (custom)
EOF

  # Generate ZSH cheatsheet
  cat > "$cheat_dir/zsh.txt" <<'EOF'
# ZSH Cheatsheet
# Advanced shell features and shortcuts

## History
!!                          # Previous command
!$                          # Last argument of previous command
!^                          # First argument of previous command
!*                          # All arguments of previous command
^old^new                    # Replace old with new in last command
Ctrl+R                      # History search (with fzf)

## Globbing
**/*.txt                    # Recursive glob
*(/)                        # Only directories
*(.)                        # Only files
*(x)                        # Only executable files
*(m-1)                      # Modified in last day
*(L0)                       # Empty files
**/*(.Lm-1)                 # Files modified in last day (recursive)

## Parameter Expansion
${var:-default}             # Use default if var unset
${var:=default}             # Assign default if var unset
${var:+alternate}           # Use alternate if var set
${#var}                     # Length of var
${var#pattern}              # Remove shortest match from start
${var##pattern}             # Remove longest match from start
${var%pattern}              # Remove shortest match from end
${var%%pattern}             # Remove longest match from end
${var/pattern/replacement}  # Replace first match
${var//pattern/replacement} # Replace all matches
${(U)var}                   # Uppercase
${(L)var}                   # Lowercase
${(C)var}                   # Capitalize

## Redirection
cmd > file                  # Redirect stdout
cmd 2> file                 # Redirect stderr
cmd &> file                 # Redirect both
cmd >> file                 # Append to file
cmd < file                  # Read from file
cmd <<< "string"            # Here string
cmd | tee file              # Write to file and stdout

## Process Management
cmd &                       # Run in background
jobs                        # List background jobs
fg                          # Bring to foreground
bg                          # Continue in background
Ctrl+Z                      # Suspend process
kill %1                     # Kill job 1
disown                      # Detach job from shell

## Aliases & Functions
alias name='command'        # Create alias
unalias name                # Remove alias
function name() { }         # Define function
name() { }                  # Alternative syntax

## Key Bindings (with fzf widgets)
Ctrl+Space                  # Universal overlay
Ctrl+F                      # File selector
Ctrl+R                      # History search
Ctrl+T                      # Tmux session selector
Alt+Y                       # Yazi file manager
Alt+J                       # Jump to bookmark
Esc Esc                     # Toggle sudo prefix
EOF

  # Generate Neovim cheatsheet
  cat > "$cheat_dir/nvim.txt" <<'EOF'
# Neovim Cheatsheet
# Essential vim/neovim commands

## Modes
i                           # Insert mode
Esc                         # Normal mode
v                           # Visual mode
V                           # Visual line mode
Ctrl+v                      # Visual block mode
:                           # Command mode

## Navigation
h j k l                     # Left, Down, Up, Right
w                           # Next word
b                           # Previous word
0                           # Start of line
$                           # End of line
gg                          # First line
G                           # Last line
{number}G                   # Go to line number
%                           # Match bracket
Ctrl+d                      # Half page down
Ctrl+u                      # Half page up
Ctrl+f                      # Page down
Ctrl+b                      # Page up

## Editing
x                           # Delete character
dd                          # Delete line
yy                          # Yank (copy) line
p                           # Paste after cursor
P                           # Paste before cursor
u                           # Undo
Ctrl+r                      # Redo
.                           # Repeat last command
ciw                         # Change inner word
di"                         # Delete inside quotes
ya{                         # Yank around braces

## Search & Replace
/pattern                    # Search forward
?pattern                    # Search backward
n                           # Next match
N                           # Previous match
*                           # Search word under cursor
:%s/old/new/g               # Replace all in file
:%s/old/new/gc              # Replace with confirmation

## Files
:w                          # Save
:q                          # Quit
:wq                         # Save and quit
:q!                         # Quit without saving
:e <file>                   # Edit file
:bn                         # Next buffer
:bp                         # Previous buffer
:bd                         # Delete buffer

## Windows & Tabs
:sp                         # Horizontal split
:vsp                        # Vertical split
Ctrl+w h/j/k/l              # Navigate splits
Ctrl+w =                    # Equal size splits
:tabnew                     # New tab
gt                          # Next tab
gT                          # Previous tab

## LSP (with built-in LSP)
gd                          # Go to definition
gr                          # Go to references
K                           # Hover documentation
[d                          # Previous diagnostic
]d                          # Next diagnostic
<leader>rn                  # Rename symbol
<leader>ca                  # Code action

## Telescope (fuzzy finder)
<leader>ff                  # Find files
<leader>fg                  # Live grep
<leader>fb                  # Find buffers
<leader>fh                  # Help tags
EOF

  echo "Cheatsheets generated in $cheat_dir" >&2
}

# Cheatsheet browser data loader
data::load::cheatsheets() {
  local cheat_dir="$BROWSER_DATA_DIR/cheatsheets"

  # Icon mapping for different cheatsheets (Nerd Font icons)
  local -A icons=(
    [git]=" "      # nf-dev-git_branch
    [docker]=" "   # nf-dev-docker
    [tmux]=" "     # nf-dev-terminal
    [zsh]=" "      # nf-dev-terminal_badge
    [nvim]=" "     # nf-dev-vim
    [default]=" "  # nf-fa-file_text_o
  )

  # List available cheatsheets with icons and descriptions
  for file in "$cheat_dir"/*.txt; do
    [[ -f "$file" ]] || continue
    local name=$(basename "$file" .txt)
    local desc=$(grep -m1 '^#' "$file" | sed 's/^# //' || echo "No description")
    local icon="${icons[$name]:-${icons[default]}}"
    printf "%s %-12s %s\n" "$icon" "$name" "$desc"
  done
}

# Cheatsheet preview function
preview::cheatsheets() {
  local selection="$1"
  local name=$(echo "$selection" | awk '{print $1}')
  local file="$BROWSER_DATA_DIR/cheatsheets/${name}.txt"

  if [[ -f "$file" ]]; then
    bat --style=plain --color=always "$file" 2>/dev/null || cat "$file"
  else
    echo "Cheatsheet not found: $name"
  fi
}

# Cheatsheet action handler
action::cheatsheets() {
  local selection="$1"
  local name=$(echo "$selection" | awk '{print $1}')
  local file="$BROWSER_DATA_DIR/cheatsheets/${name}.txt"

  if [[ -f "$file" ]]; then
    # Show in pager
    ${PAGER:-less} "$file"
  fi
}

# Main cheatsheet browser function
browser::cheatsheets() {
  local data_file="$BROWSER_DATA_DIR/cheatsheets/git.txt"

  # Ensure data exists
  data::ensure cheatsheets "$data_file" || return 1

  # Inline preview command (fzf runs in subshell, can't access functions)
  # Extract name from second field (first is icon)
  local preview_cmd="name=\$(echo {} | awk '{print \$2}'); file=\"$BROWSER_DATA_DIR/cheatsheets/\${name}.txt\"; bat --style=plain --color=always \"\$file\" 2>/dev/null || cat \"\$file\""

  # Multi-line header with help text
  local header=$'Navigate: ↑↓ PageUp/PageDown | Select: Enter | Quit: Esc\nPreview: Ctrl+/ to toggle | View full: Enter\n─────────────────────────────────────────'

  # Run browser
  browser::base \
    "Cheatsheets" \
    "data::load::cheatsheets" \
    "$preview_cmd" \
    "$header" \
    "action::cheatsheets" \
    "╣ Command Reference ╠"
}

# Cheatsheet widget
widget::cheatsheets() {
  browser::widget browser::cheatsheets none
}
zle -N widget::cheatsheets

#=============================================================================
# BROWSER: THEMES (Wezterm/Tmux/P10k)
#=============================================================================

# Note: Theme browsers are more complex and will be migrated from existing
# implementations. This is a placeholder showing the integration pattern.

# browser::themes::wezterm() {
#   # Implementation will migrate from wezterm/scripts/theme-browser/
#   # Uses existing theme-browser.sh logic with new framework
# }

#=============================================================================
# BROWSER: KEYMAPS
#=============================================================================

# Note: Keymap browser will migrate from existing implementations
# Similar pattern to cheatsheets but with JSON data

# browser::keymaps::wezterm() {
#   # Migrate from wezterm/scripts/keymap-browser/
# }

#=============================================================================
# BROWSER: FONTS
#=============================================================================

# Data generator for system fonts
data::generate::fonts() {
  local font_dir="$BROWSER_DATA_DIR/fonts"
  mkdir -p "$font_dir"

  # Generate system fonts list
  fc-list : family style | sort -u > "$font_dir/system.txt"

  echo "Font list generated in $font_dir" >&2
}

# Font browser
browser::fonts() {
  local data_file="$BROWSER_DATA_DIR/fonts/system.txt"

  # Ensure data exists
  data::ensure fonts "$data_file" || return 1

  # Simple browser - copy font name to clipboard
  local selection
  selection=$(data::load "$data_file" | \
    fzf $(_fzf_base_opts) \
      --height=100% \
      --prompt="Fonts ❯ " \
      --header="Select font | Ctrl+Y: copy to clipboard" \
      --preview='echo "Font: {}"' \
      --bind='ctrl-y:execute-silent(echo -n {} | wl-copy)+abort')

  [[ -n "$selection" ]] && echo "$selection"
}

#=============================================================================
# BROWSER: REGEX PATTERNS
#=============================================================================

# Data generator for regex patterns
data::generate::regex() {
  local regex_dir="$BROWSER_DATA_DIR/regex"
  mkdir -p "$regex_dir"

  # Generate common regex patterns
  cat > "$regex_dir/patterns.json" <<'EOF'
{
  "patterns": [
    {
      "name": "Email",
      "pattern": "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
      "description": "Match email addresses",
      "example": "user@example.com"
    },
    {
      "name": "URL",
      "pattern": "https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}[/\\w .-]*",
      "description": "Match HTTP(S) URLs",
      "example": "https://example.com/path"
    },
    {
      "name": "IPv4",
      "pattern": "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b",
      "description": "Match IPv4 addresses",
      "example": "192.168.1.1"
    },
    {
      "name": "IPv6",
      "pattern": "([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}",
      "description": "Match IPv6 addresses",
      "example": "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    },
    {
      "name": "Phone (US)",
      "pattern": "\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})",
      "description": "Match US phone numbers",
      "example": "(123) 456-7890"
    },
    {
      "name": "Date (YYYY-MM-DD)",
      "pattern": "\\d{4}-\\d{2}-\\d{2}",
      "description": "Match ISO date format",
      "example": "2024-11-30"
    },
    {
      "name": "Time (HH:MM)",
      "pattern": "([01]?[0-9]|2[0-3]):[0-5][0-9]",
      "description": "Match 24-hour time",
      "example": "14:30"
    },
    {
      "name": "Hex Color",
      "pattern": "#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})",
      "description": "Match hexadecimal color codes",
      "example": "#FF5733"
    },
    {
      "name": "Username",
      "pattern": "^[a-zA-Z0-9_-]{3,16}$",
      "description": "Match valid usernames (3-16 chars)",
      "example": "user_name123"
    },
    {
      "name": "Git SHA",
      "pattern": "\\b[0-9a-f]{7,40}\\b",
      "description": "Match git commit hashes",
      "example": "a1b2c3d"
    },
    {
      "name": "UUID",
      "pattern": "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
      "description": "Match UUIDs",
      "example": "550e8400-e29b-41d4-a716-446655440000"
    },
    {
      "name": "Markdown Link",
      "pattern": "\\[([^\\]]+)\\]\\(([^\\)]+)\\)",
      "description": "Match markdown links",
      "example": "[text](url)"
    }
  ]
}
EOF

  echo "Regex patterns generated in $regex_dir" >&2
}

# Regex browser data loader
data::load::regex() {
  local regex_file="$BROWSER_DATA_DIR/regex/patterns.json"

  if (( $+commands[jq] )); then
    jq -r '.patterns[] | "\(.name)|\(.pattern)|\(.description)"' "$regex_file" | \
      while IFS='|' read -r name pattern description; do
        printf "%-20s  %-40s  %s\n" "$name" "$pattern" "$description"
      done
  else
    echo "jq required for regex browser" >&2
    return 1
  fi
}

# Regex preview
preview::regex() {
  local selection="$1"
  local name=$(echo "$selection" | awk '{print $1}')
  local regex_file="$BROWSER_DATA_DIR/regex/patterns.json"

  if (( $+commands[jq] )); then
    jq -r --arg name "$name" \
      '.patterns[] | select(.name == $name) |
       "Pattern: \(.pattern)\n\nDescription: \(.description)\n\nExample: \(.example)"' \
      "$regex_file"
  fi
}

# Regex action - copy pattern to clipboard
action::regex() {
  local selection="$1"
  local pattern=$(echo "$selection" | awk '{print $2}')

  if (( $+commands[wl-copy] )); then
    echo -n "$pattern" | wl-copy
    echo "Pattern copied to clipboard: $pattern" >&2
  else
    echo "$pattern"
  fi
}

# Main regex browser
browser::regex() {
  local data_file="$BROWSER_DATA_DIR/regex/patterns.json"

  # Ensure data exists
  data::ensure regex "$data_file" || return 1

  # Run browser
  browser::base \
    "Regex Patterns" \
    "data::load::regex" \
    "preview::regex {}" \
    "Select pattern | Ctrl+Y: copy to clipboard" \
    "action::regex"
}

# Regex widget
widget::regex() {
  browser::widget browser::regex none
}
zle -N widget::regex

#=============================================================================
# BROWSER: SNIPPETS
#=============================================================================

# Snippet browser placeholder - demonstrates nested browsing
# First select language, then select snippet from that language

browser::snippets() {
  echo "Snippet browser - coming soon"
  echo "Will support multi-language code snippets with syntax highlighting"
}

#=============================================================================
# UTILITY FUNCTIONS
#=============================================================================

# Function: browser::list
# Description: List all available browsers
browser::list() {
  echo "Available Browsers:"
  echo "  browser::cheatsheets  - Command reference sheets"
  echo "  browser::regex        - Regex pattern library"
  echo "  browser::fonts        - System font browser"
  echo "  browser::snippets     - Code snippet library (coming soon)"
  echo ""
  echo "To add to existing implementations:"
  echo "  browser::themes       - Theme selector (wezterm/tmux/p10k)"
  echo "  browser::keymaps      - Keymap reference"
  echo "  browser::nerdfonts    - Nerd font icon picker"
}

# Function: data::generate::all
# Description: Generate all browser data files
data::generate::all() {
  echo "Generating all browser data..."

  local generators=(
    cheatsheets
    fonts
    regex
  )

  for gen in "${generators[@]}"; do
    if (( $+functions[data::generate::$gen] )); then
      echo "Generating: $gen"
      data::generate::$gen
    fi
  done

  echo "Data generation complete!"
}

#=============================================================================
# KEYBINDINGS
#=============================================================================

# Suggested keybindings (add to your .zshrc or keybindings file):
# bindkey '^X^C' widget::cheatsheets  # Ctrl+X Ctrl+C
# bindkey '^X^R' widget::regex        # Ctrl+X Ctrl+R

#=============================================================================
# INTEGRATION EXAMPLES
#=============================================================================

# Shell usage:
#   browser::cheatsheets
#   browser::regex
#
# Tmux integration (in tmux.conf):
#   bind-key C run-shell "zsh -ic 'browser::cheatsheets'"
#
# Wezterm integration (in wezterm.lua):
#   wezterm.action.SpawnCommand {
#     args = { 'zsh', '-ic', 'browser::cheatsheets' }
#   }
#
# Widget usage (after registering with bindkey):
#   Ctrl+X Ctrl+C (or your chosen binding)

# vim: ft=zsh:et:sw=2:ts=2:sts=2
