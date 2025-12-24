#!/usr/bin/env zsh
# =============================================================================
# CORE Shell Main Menu System
# =============================================================================
# Purpose: Central command hub providing unified access to all shell utilities,
#          FZF customization, system tools, and documentation.
#
# Keybindings:
#   Ctrl+Space  - Main menu launcher
#   Alt+M       - Alternate main menu keybind
#
# Dependencies:
#   - fzf: Required for all menu interfaces
#   - bat: Enhanced preview support
#   - fd: Fast file finding
#   - rg: Fast content search
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
typeset -g CORE_MENU_VERSION="1.0.0"
typeset -g CORE_MENU_HEADER="CORE Shell Menu"

# Menu categories with icons and descriptions
typeset -gA CORE_MENU_CATEGORIES=(
    [fzf]="FZF Customization|Configure FZF appearance, themes, and layouts"
    [files]="File Operations|File and directory navigation widgets"
    [git]="Git Operations|Git status, branches, commits, and staging"
    [system]="System Tools|Systemd, processes, network, and containers"
    [tmux]="Tmux|Session, window, and pane management"
    [shell]="Shell Utilities|History, clipboard, bookmarks, and notes"
    [docs]="Documentation|Browse and search documentation"
    [dev]="Development|Language-specific tools and project helpers"
)

# =============================================================================
# Main Menu Function
# =============================================================================

# Function: core-menu
# Description: Main entry point for the shell menu system
# Usage: core-menu [category]
core-menu() {
    local category="${1:-}"
    local choice

    if [[ -n "$category" ]]; then
        # Direct category access
        _core_menu_show_category "$category"
        return
    fi

    # Build category list
    local -a categories=()
    for key in "${(@k)CORE_MENU_CATEGORIES}"; do
        local parts=("${(@s:|:)CORE_MENU_CATEGORIES[$key]}")
        categories+=("$key|${parts[1]}|${parts[2]}")
    done

    # Sort categories alphabetically
    categories=(${(o)categories})

    # Show category selector
    choice=$(printf '%s\n' "${categories[@]}" | \
        fzf --delimiter='|' \
            --with-nth=2,3 \
            --header="$CORE_MENU_HEADER v$CORE_MENU_VERSION" \
            --prompt='Menu> ' \
            --height=70% \
            --layout=reverse \
            --border=double \
            --border-label="[ Main Menu ]" \
            --preview='
                category=$(echo {} | cut -d"|" -f1)
                case "$category" in
                    fzf)
                        echo -e "\033[1;36m=== FZF Customization ===\033[0m\n"
                        echo "Customize FZF appearance in real-time:"
                        echo ""
                        echo "  - Color themes (10+ options)"
                        echo "  - Layout presets (10+ layouts)"
                        echo "  - Preview window position/size"
                        echo "  - Keybinding customization"
                        echo "  - Save/restore preferences"
                        ;;
                    files)
                        echo -e "\033[1;36m=== File Operations ===\033[0m\n"
                        echo "File and directory widgets:"
                        echo ""
                        echo "  Ctrl+F  - Find files"
                        echo "  Alt+F   - Find directories"
                        echo "  Alt+Y   - Yazi file picker"
                        echo "  Ctrl+Y  - Yazi with cd"
                        echo "  Alt+Z   - Zoxide jump"
                        ;;
                    git)
                        echo -e "\033[1;36m=== Git Operations ===\033[0m\n"
                        echo "Git integration widgets:"
                        echo ""
                        echo "  Ctrl+G     - Git status files"
                        echo "  Alt+G      - Git branches"
                        echo "  Alt+C      - Git commits"
                        echo "  Alt+R      - Git remotes"
                        echo "  Ctrl+G A   - Git add (fuzzy)"
                        ;;
                    system)
                        echo -e "\033[1;36m=== System Tools ===\033[0m\n"
                        echo "System management widgets:"
                        echo ""
                        echo "  Ctrl+Alt+S - Systemd manager"
                        echo "  Ctrl+Alt+J - Journal browser"
                        echo "  Ctrl+Alt+D - Docker containers"
                        echo "  Ctrl+Alt+N - Network manager"
                        echo "  Ctrl+Alt+P - Process manager"
                        ;;
                    tmux)
                        echo -e "\033[1;36m=== Tmux Integration ===\033[0m\n"
                        echo "Tmux session management:"
                        echo ""
                        echo "  Ctrl+T  - Tmux sessions"
                        echo "  Alt+T   - Tmux windows"
                        echo "  Alt+P   - Tmux panes"
                        echo "  flayout - Tmux layouts"
                        ;;
                    shell)
                        echo -e "\033[1;36m=== Shell Utilities ===\033[0m\n"
                        echo "Shell productivity tools:"
                        echo ""
                        echo "  Ctrl+R  - History search"
                        echo "  Alt+W   - Copy buffer"
                        echo "  Alt+V   - Paste clipboard"
                        echo "  Alt+B   - Bookmark directory"
                        echo "  Alt+J   - Jump to bookmark"
                        echo "  Alt+N   - Quick note"
                        ;;
                    docs)
                        echo -e "\033[1;36m=== Documentation ===\033[0m\n"
                        echo "Documentation system:"
                        echo ""
                        echo "  docs    - Main doc menu"
                        echo "  docb    - Browse docs"
                        echo "  docq    - Quick reference"
                        echo "  doch    - Context help"
                        echo "  doci    - Doc index"
                        ;;
                    dev)
                        echo -e "\033[1;36m=== Development Tools ===\033[0m\n"
                        echo "Development helpers:"
                        echo ""
                        echo "  fnpm   - NPM script runner"
                        echo "  fpac   - Package install"
                        echo "  fenv   - Environment vars"
                        echo "  fman   - Man page browser"
                        ;;
                esac
            ' \
            --preview-window='right:50%:wrap')

    [[ -z "$choice" ]] && return 0

    category=$(echo "$choice" | cut -d'|' -f1)
    _core_menu_show_category "$category"
}

# =============================================================================
# Category Submenus
# =============================================================================

_core_menu_show_category() {
    local category="$1"

    case "$category" in
        fzf) _core_menu_fzf ;;
        files) _core_menu_files ;;
        git) _core_menu_git ;;
        system) _core_menu_system ;;
        tmux) _core_menu_tmux ;;
        shell) _core_menu_shell ;;
        docs) _core_menu_docs ;;
        dev) _core_menu_dev ;;
        *) echo "Unknown category: $category" ;;
    esac
}

# -----------------------------------------------------------------------------
# FZF Customization Menu
# -----------------------------------------------------------------------------
_core_menu_fzf() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="FZF Customization" --prompt="FZF> " --height=60% --layout=reverse --border=rounded --preview-window='right:50%:wrap' --preview='
        option=$(echo {} | cut -d"|" -f1)
        case "$option" in
            themes)
                echo -e "\033[1;36m=== Available Themes ===\033[0m\n"
                for f in "${CORE_CFG:-$HOME/.core/.sys/cfg}"/zsh/integrations/themes/fzf/*.zsh; do
                    [[ -f "$f" ]] && basename "$f" .zsh
                done 2>/dev/null
                ;;
            layouts)
                echo -e "\033[1;36m=== Available Layouts ===\033[0m\n"
                for f in "${CORE_CFG:-$HOME/.core/.sys/cfg}"/zsh/integrations/themes/fzf/layouts/*.zsh; do
                    [[ -f "$f" ]] && basename "$f" .zsh
                done 2>/dev/null
                ;;
            current)
                echo -e "\033[1;36m=== Current Configuration ===\033[0m\n"
                echo "Theme: $(cat ~/.local/state/fzf/current-theme 2>/dev/null || echo default)"
                echo "Layout: $(cat ~/.local/state/fzf/current-layout 2>/dev/null || echo default)"
                ;;
            preview)
                echo -e "\033[1;36m=== Theme Preview ===\033[0m\n"
                echo "Opens interactive theme preview mode."
                echo "Navigate themes with n/p keys."
                ;;
            reset)
                echo -e "\033[1;36m=== Reset to Defaults ===\033[0m\n"
                echo "Removes saved theme and layout preferences."
                echo "Restores default FZF appearance."
                ;;
        esac
    '
themes|Select Color Theme|Choose from 10+ color themes
layouts|Select Layout|Choose window layout and styling
current|Show Current|Display current theme and layout
preview|Live Preview|Preview themes interactively
reset|Reset to Defaults|Remove custom preferences
appearance|Appearance Menu|Combined theme/layout selector
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        themes)
            (( $+functions[fzf-theme-select] )) && fzf-theme-select || echo "fzf-theme module not loaded"
            ;;
        layouts)
            (( $+functions[fzf-layout-select] )) && fzf-layout-select || echo "fzf-theme module not loaded"
            ;;
        current)
            (( $+functions[fzf-show-current] )) && fzf-show-current || {
                echo "Current FZF Configuration:"
                echo "Theme: $(cat ~/.local/state/fzf/current-theme 2>/dev/null || echo default)"
                echo "Layout: $(cat ~/.local/state/fzf/current-layout 2>/dev/null || echo default)"
            }
            ;;
        preview)
            (( $+functions[fzf-theme-preview] )) && fzf-theme-preview || echo "Theme preview not available"
            ;;
        reset)
            rm -f ~/.local/state/fzf/current-theme ~/.local/state/fzf/current-layout
            unset _FZF_THEME_COLORS _FZF_LAYOUT_OPTS
            (( $+functions[_fzf_rebuild_opts] )) && _fzf_rebuild_opts
            echo "Reset to default FZF configuration"
            ;;
        appearance)
            (( $+functions[fzf-appearance] )) && fzf-appearance || echo "fzf-theme module not loaded"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# File Operations Menu
# -----------------------------------------------------------------------------
_core_menu_files() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="File Operations" --prompt="Files> " --height=60% --layout=reverse --border=rounded
find-files|Find Files|Ctrl+F - Search files with preview
find-dirs|Find Directories|Alt+F - Search directories
yazi-pick|Yazi Picker|Alt+Y - Select files with Yazi
yazi-cd|Yazi Navigate|Ctrl+Y - Navigate with Yazi
zoxide|Zoxide Jump|Alt+Z - Smart directory jump
bookmarks|Bookmarks|Alt+J - Jump to bookmarked directory
bookmark-add|Add Bookmark|Alt+B - Bookmark current directory
recent|Recent Files|Recently accessed files
tree|Directory Tree|Show directory tree structure
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        find-files)
            zle -N widget::fzf-file-selector 2>/dev/null
            widget::fzf-file-selector
            ;;
        find-dirs)
            zle -N widget::fzf-directory-selector 2>/dev/null
            widget::fzf-directory-selector
            ;;
        yazi-pick)
            widget::yazi-picker 2>/dev/null || echo "Yazi widget not available"
            ;;
        yazi-cd)
            widget::yazi-cd 2>/dev/null || yazi
            ;;
        zoxide)
            widget::zoxide-interactive 2>/dev/null || zi
            ;;
        bookmarks)
            widget::jump-bookmark 2>/dev/null
            ;;
        bookmark-add)
            widget::bookmark-directory 2>/dev/null
            ;;
        recent)
            fd --type f --hidden --changed-within 1d 2>/dev/null | \
                fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null | head -50' \
                    --header "Recent Files (last 24h)"
            ;;
        tree)
            eza -T --icons -L 3 --color=always 2>/dev/null | less -R
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Git Operations Menu
# -----------------------------------------------------------------------------
_core_menu_git() {
    # Check if in git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Not in a git repository"
        return 1
    fi

    local choice

    choice=$(cat << 'EOF' | fzf --header="Git Operations" --prompt="Git> " --height=60% --layout=reverse --border=rounded --preview='
        option=$(echo {} | cut -d"|" -f1)
        case "$option" in
            status) git status --short ;;
            diff) git diff --stat ;;
            branches) git branch -av ;;
            log) git log --oneline --graph -15 ;;
            stash) git stash list ;;
        esac 2>/dev/null
    ' --preview-window='right:50%:wrap'
status|Git Status|Ctrl+G - View and select modified files
add|Git Add|Stage files interactively
branches|Git Branches|Alt+G - Switch branches
commits|Git Commits|Alt+C - Browse commits
remotes|Git Remotes|Alt+R - Manage remotes
diff|Git Diff|View unstaged changes
log|Git Log|Browse commit history
stash|Git Stash|Manage stash entries
checkout|Checkout Files|Restore modified files
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        status)
            widget::fzf-git-status 2>/dev/null
            ;;
        add)
            fzf-git-add 2>/dev/null
            ;;
        branches)
            widget::fzf-git-branch 2>/dev/null
            ;;
        commits)
            widget::fzf-git-commits 2>/dev/null
            ;;
        remotes)
            widget::fzf-git-remotes 2>/dev/null
            ;;
        diff)
            git diff | delta 2>/dev/null || git diff | less -R
            ;;
        log)
            git log --oneline --graph --color=always | \
                fzf --ansi --no-sort --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)' \
                    --preview-window='right:60%:wrap' \
                    --bind 'enter:execute(git show $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | less -R)'
            ;;
        stash)
            git stash list | fzf --preview 'git stash show -p $(echo {} | cut -d: -f1)' \
                --bind 'enter:execute(git stash pop $(echo {} | cut -d: -f1))'
            ;;
        checkout)
            fzf-git-checkout-file 2>/dev/null
            ;;
    esac
}

# -----------------------------------------------------------------------------
# System Tools Menu
# -----------------------------------------------------------------------------
_core_menu_system() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="System Tools" --prompt="System> " --height=60% --layout=reverse --border=rounded
systemd|Systemd Manager|Ctrl+Alt+S - Manage systemd units
journal|Journal Browser|Ctrl+Alt+J - Browse system logs
docker|Docker Containers|Ctrl+Alt+D - Container management
docker-img|Docker Images|Ctrl+Alt+I - Image management
compose|Docker Compose|Ctrl+Alt+C - Compose management
processes|Process Manager|Ctrl+Alt+P - Manage processes
network|Network Manager|Ctrl+Alt+N - Network configuration
ports|Listening Ports|Show processes on ports
disk|Disk Usage|Show disk space usage
memory|Memory Info|Show memory usage
hardware|Hardware Info|System hardware details
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        systemd)
            widget::systemd-unit-manager 2>/dev/null || fzf-systemctl
            ;;
        journal)
            widget::systemd-journal-browser 2>/dev/null || journalctl -f
            ;;
        docker)
            widget::docker-container-manager 2>/dev/null || docker ps -a
            ;;
        docker-img)
            widget::docker-image-manager 2>/dev/null || docker images
            ;;
        compose)
            widget::docker-compose-manager 2>/dev/null
            ;;
        processes)
            widget::process-manager 2>/dev/null || htop
            ;;
        network)
            widget::network-manager 2>/dev/null
            ;;
        ports)
            ss -tulpn 2>/dev/null | fzf --header-lines=1 --header "Listening Ports"
            ;;
        disk)
            duf 2>/dev/null || df -h
            ;;
        memory)
            free -h && echo "" && ps aux --sort=-%mem | head -10
            ;;
        hardware)
            echo "=== CPU ===" && lscpu | head -15
            echo ""
            echo "=== Memory ===" && free -h
            echo ""
            echo "=== Storage ===" && lsblk
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Tmux Menu
# -----------------------------------------------------------------------------
_core_menu_tmux() {
    if [[ -z "$TMUX" ]]; then
        echo "Not in a tmux session"
        local sessions=$(tmux list-sessions 2>/dev/null)
        if [[ -n "$sessions" ]]; then
            echo ""
            echo "Available sessions:"
            echo "$sessions"
            echo ""
            echo -n "Attach to session? [y/N]: "
            read -q && {
                echo ""
                local sess=$(echo "$sessions" | fzf --height=30% | cut -d: -f1)
                [[ -n "$sess" ]] && tmux attach -t "$sess"
            }
        fi
        return 0
    fi

    local choice

    choice=$(cat << 'EOF' | fzf --header="Tmux Management" --prompt="Tmux> " --height=60% --layout=reverse --border=rounded
sessions|Switch Session|Ctrl+T - Switch to another session
windows|Switch Window|Alt+T - Switch windows
panes|Switch Pane|Alt+P - Navigate panes
layouts|Tmux Layouts|Apply preset pane layouts
new-session|New Session|Create a new session
new-window|New Window|Create new window
split-h|Split Horizontal|Split pane horizontally
split-v|Split Vertical|Split pane vertically
rename|Rename|Rename session or window
kill|Kill|Kill pane/window/session
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        sessions)
            widget::fzf-tmux-session 2>/dev/null
            ;;
        windows)
            widget::fzf-tmux-window 2>/dev/null
            ;;
        panes)
            widget::fzf-tmux-pane 2>/dev/null
            ;;
        layouts)
            fzf-tmux-layouts 2>/dev/null
            ;;
        new-session)
            local name
            vared -p "Session name: " name
            [[ -n "$name" ]] && tmux new-session -d -s "$name" && tmux switch-client -t "$name"
            ;;
        new-window)
            local name
            vared -p "Window name: " name
            [[ -n "$name" ]] && tmux new-window -n "$name" || tmux new-window
            ;;
        split-h)
            tmux split-window -h
            ;;
        split-v)
            tmux split-window -v
            ;;
        rename)
            local what=$(echo "session\nwindow" | fzf --height=20% --header "Rename what?")
            local name
            vared -p "New name: " name
            case "$what" in
                session) [[ -n "$name" ]] && tmux rename-session "$name" ;;
                window) [[ -n "$name" ]] && tmux rename-window "$name" ;;
            esac
            ;;
        kill)
            local what=$(echo "pane\nwindow\nsession" | fzf --height=20% --header "Kill what?")
            case "$what" in
                pane) tmux kill-pane ;;
                window) tmux kill-window ;;
                session)
                    local sess=$(tmux list-sessions | fzf --height=30% | cut -d: -f1)
                    [[ -n "$sess" ]] && tmux kill-session -t "$sess"
                    ;;
            esac
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Shell Utilities Menu
# -----------------------------------------------------------------------------
_core_menu_shell() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="Shell Utilities" --prompt="Shell> " --height=60% --layout=reverse --border=rounded
history|History Search|Ctrl+R - Search command history
clipboard|Clipboard History|Ctrl+Alt+V - Browse clipboard
bookmarks|Directory Bookmarks|Alt+J - Jump to bookmarks
notes|Quick Notes|Alt+N - Take quick notes
env|Environment|Alt+E - Browse/edit env vars
aliases|Aliases|View and expand aliases
functions|Functions|Browse defined functions
keybindings|Keybindings|Show all keybindings
palette|Command Palette|Ctrl+P - Quick commands
calculator|Calculator|Alt+= - Evaluate expression
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        history)
            widget::fzf-history-search 2>/dev/null || fc -l -50
            ;;
        clipboard)
            widget::clipboard-history-manager 2>/dev/null || fzf-cliphist
            ;;
        bookmarks)
            widget::jump-bookmark 2>/dev/null
            ;;
        notes)
            widget::quick-note 2>/dev/null
            ;;
        env)
            widget::fzf-env 2>/dev/null || fzf-environment
            ;;
        aliases)
            alias | fzf --header "Aliases" --preview 'echo "Expands to: $(echo {} | cut -d= -f2-)"' \
                --preview-window='down:3:wrap'
            ;;
        functions)
            typeset -f | grep "^[a-z_-]* ()" | sed 's/ ().*//' | sort | \
                fzf --header "Functions" \
                    --preview 'typeset -f {} | bat --style=plain --color=always -l bash' \
                    --preview-window='right:60%:wrap'
            ;;
        keybindings)
            widget::show-keybindings 2>/dev/null || bindkey | fzf --header "Keybindings"
            ;;
        palette)
            widget::command-palette 2>/dev/null
            ;;
        calculator)
            widget::calculator 2>/dev/null
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Documentation Menu
# -----------------------------------------------------------------------------
_core_menu_docs() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="Documentation" --prompt="Docs> " --height=60% --layout=reverse --border=rounded
browse|Browse Docs|Browse documentation by category
search|Search Docs|Search across all documentation
quick-ref|Quick Reference|Functions, widgets, keybindings
context|Context Help|Documentation for current directory
add|Add Document|Create new documentation
edit|Edit Document|Edit existing documentation
generate|Generate Docs|Generate docs from code comments
index|Doc Index|View documentation index
man|Man Pages|Browse man pages with fzf
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        browse)
            doc-browse 2>/dev/null || echo "Documentation system not loaded"
            ;;
        search)
            doc-search 2>/dev/null
            ;;
        quick-ref)
            doc-quick-ref 2>/dev/null
            ;;
        context)
            doc-context 2>/dev/null
            ;;
        add)
            doc-add 2>/dev/null
            ;;
        edit)
            doc-edit 2>/dev/null
            ;;
        generate)
            local file=$(find "${ZSH_CORE:-$HOME/.core/.sys/cfg/zsh}" -name "*.zsh" | \
                fzf --header "Select file to generate docs" \
                    --preview 'bat --color=always {}')
            [[ -n "$file" ]] && doc-generate "$file" 2>/dev/null
            ;;
        index)
            doc-index 2>/dev/null
            ;;
        man)
            fzf-man 2>/dev/null || man -k . | fzf --preview 'man $(echo {} | awk "{print \$1}")' | awk '{print $1}' | xargs -r man
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Development Tools Menu
# -----------------------------------------------------------------------------
_core_menu_dev() {
    local choice

    choice=$(cat << 'EOF' | fzf --header="Development Tools" --prompt="Dev> " --height=60% --layout=reverse --border=rounded
npm|NPM Scripts|Run npm/pnpm scripts
packages|Install Packages|Fuzzy package installer
env-edit|Edit Environment|Browse and modify env vars
json|JSON Tools|Format and query JSON
http|HTTP Client|Quick HTTP requests
ssh|SSH Hosts|Alt+S - Connect to SSH hosts
ports|Port Scanner|Find open ports
logs|Log Viewer|Tail and search log files
config|Edit Configs|Edit config files
workspace|Workspace|Launch workspace layouts
EOF
    )

    [[ -z "$choice" ]] && return 0

    local option=$(echo "$choice" | cut -d'|' -f1)

    case "$option" in
        npm)
            fzf-npm-scripts 2>/dev/null || {
                [[ -f package.json ]] && jq -r '.scripts | keys[]' package.json | \
                    fzf --preview 'jq -r ".scripts.\"{}\"" package.json' | \
                    xargs -r npm run
            }
            ;;
        packages)
            fzf-pacman-install 2>/dev/null
            ;;
        env-edit)
            fzf-environment 2>/dev/null
            ;;
        json)
            local file=$(fd -e json | fzf --header "Select JSON file" \
                --preview 'jq -C . {} 2>/dev/null | head -50')
            [[ -n "$file" ]] && {
                local action=$(echo "view\nformat\nquery\nedit" | fzf --header "Action")
                case "$action" in
                    view) jq -C . "$file" | less -R ;;
                    format) jq . "$file" > "${file}.formatted" && mv "${file}.formatted" "$file" && echo "Formatted: $file" ;;
                    query)
                        local query
                        vared -p "JQ query: " query
                        [[ -n "$query" ]] && jq "$query" "$file"
                        ;;
                    edit) ${EDITOR:-nvim} "$file" ;;
                esac
            }
            ;;
        http)
            local method=$(echo "GET\nPOST\nPUT\nDELETE\nHEAD" | fzf --header "HTTP Method")
            local url
            vared -p "URL: " url
            [[ -n "$url" && -n "$method" ]] && curl -X "$method" -i "$url"
            ;;
        ssh)
            widget::fzf-ssh 2>/dev/null || f1ssh
            ;;
        ports)
            fzf-kill-port 2>/dev/null
            ;;
        logs)
            local log=$(fd -e log -e txt . /var/log ~/.local/state 2>/dev/null | \
                fzf --header "Select log file" \
                    --preview 'tail -50 {}')
            [[ -n "$log" ]] && tail -f "$log" | bat --style=plain --paging=never
            ;;
        config)
            local config=$(fd -e conf -e ini -e yaml -e yml -e toml -e json . ~/.config ~/.core 2>/dev/null | \
                fzf --header "Select config file" \
                    --preview 'bat --color=always {}')
            [[ -n "$config" ]] && ${EDITOR:-nvim} "$config"
            ;;
        workspace)
            widget::workspace-launcher 2>/dev/null
            ;;
    esac
}

# =============================================================================
# ZLE Widget for Menu Access
# =============================================================================

# Widget: _core_menu_widget
# Description: ZLE widget to launch main menu
function _core_menu_widget() {
    zle -I
    core-menu
    zle reset-prompt
}
zle -N _core_menu_widget

# Quick category widgets
function _core_menu_fzf_widget() {
    zle -I
    _core_menu_fzf
    zle reset-prompt
}
zle -N _core_menu_fzf_widget

function _core_menu_git_widget() {
    zle -I
    _core_menu_git
    zle reset-prompt
}
zle -N _core_menu_git_widget

function _core_menu_system_widget() {
    zle -I
    _core_menu_system
    zle reset-prompt
}
zle -N _core_menu_system_widget

# =============================================================================
# Keybindings
# =============================================================================
# Main menu: Ctrl+Space (^@) or Alt+M
# NOTE: Keybindings moved to zvm_after_init to avoid conflicts with zsh-vi-mode
# See 02-zinit.zsh for the zvm_after_init_commands configuration


# Quick access to FZF customization: Ctrl+Alt+F
bindkey '^[^f' _core_menu_fzf_widget

# =============================================================================
# Aliases for Command-line Access
# =============================================================================
alias menu='core-menu'
alias m='core-menu'
alias mf='core-menu fzf'
alias mg='core-menu git'
alias ms='core-menu system'
alias mt='core-menu tmux'
alias msh='core-menu shell'
alias md='core-menu docs'
alias mdev='core-menu dev'

# =============================================================================
# Initialization Message
# =============================================================================
[[ -o interactive ]] && {
    # Only show on first load
    if [[ -z "$_CORE_MENU_LOADED" ]]; then
        typeset -g _CORE_MENU_LOADED=1
    fi
}
