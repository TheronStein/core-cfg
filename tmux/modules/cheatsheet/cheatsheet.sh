# Dynamic Cheatsheet Browser
# Reads markdown files from directory structure and displays with fzf + bat

CHEAT_DIR="${CHEAT_DIR:-$CORE/vaults/cheatsheets}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons for visual distinction
DIR_ICON="📁"
FILE_ICON="📄"
MD_ICON="📋"

# Check dependencies
check_dependencies() {
    local missing=()

    if ! command -v fzf >/dev/null 2>&1; then
        missing+=("fzf")
    fi

    if ! command -v bat >/dev/null 2>&1; then
        missing+=("bat")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}"
        echo -e "${BLUE}Install with your package manager${NC}"
        exit 1
    fi
}

# Preview function for fzf
preview_item() {
    local line="$1"
    local type=$(echo "$line" | cut -d'|' -f1)
    local path=$(echo "$line" | cut -d'|' -f4)

    if [[ "$type" == "FILE" ]]; then
        if [[ -f "$path" ]]; then
            # Show file content with bat
            bat "$path" \
                --color=always \
                --style=header,grid,numbers \
                --theme=ansi \
                --terminal-width=$(($(tput cols) - 20)) 2>/dev/null ||
                cat "$path"
        else
            echo "File not found: $path"
        fi
    elif [[ "$type" == "DIR" ]]; then
        # Show directory contents
        echo -e "${BLUE}📁 Directory: $(basename "$path")${NC}\n"
        if command -v tree >/dev/null 2>&1; then
            tree "$path" -L 2 -a --dirsfirst 2>/dev/null ||
                ls -la "$path"
        else
            ls -la "$path" | head -20
        fi
    fi
}

# Export function for fzf
export -f preview_item

# Interactive browser
interactive_browser() {
    local tree_output
    tree_output=$(build_tree "$CHEAT_DIR")

    if [[ -z "$tree_output" ]]; then
        echo -e "${YELLOW}No files found in $CHEAT_DIR${NC}"
        read -p "Create sample structure? [Y/n] " response
        if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
            create_sample_structure
            tree_output=$(build_tree "$CHEAT_DIR")
        else
            exit 0
        fi
    fi

    echo -e "${BLUE}📚 Cheatsheet Browser${NC}"
    echo -e "${CYAN}Directory: $CHEAT_DIR${NC}"
    echo ""

    local selected
    selected=$(echo "$tree_output" |
        fzf --ansi \
            --prompt="📋 " \
            --header="Select cheatsheet (directories show contents, files show content)" \
            --preview="preview_item {}" \
            --preview-window="right:60%:wrap" \
            --with-nth=3 \
            --delimiter='|' \
            --border \
            --height=80% \
            --bind="ctrl-r:reload($(declare -f build_tree); build_tree '$CHEAT_DIR')" \
            --bind="ctrl-e:execute(vim {4})" \
            --bind="ctrl-o:execute(open {4})" \
            --info=inline)

    if [[ -n "$selected" ]]; then
        local type=$(echo "$selected" | cut -d'|' -f1)
        local path=$(echo "$selected" | cut -d'|' -f4)

        if [[ "$type" == "FILE" ]]; then
            # Display file with bat
            clear
            echo -e "${GREEN}📋 $(basename "$path")${NC}"
            echo -e "${CYAN}$path${NC}"
            echo "================================"
            bat "$path" \
                --color=always \
                --style=header,grid,numbers \
                --theme=ansi \
                --paging=never 2>/dev/null || cat "$path"
        elif [[ "$type" == "DIR" ]]; then
            echo -e "${BLUE}📁 Directory selected: $path${NC}"
            # Could implement directory browsing here
        fi
    fi
}

# Tmux popup integration
tmux_popup() {
    if [[ -z "$TMUX" ]]; then
        echo -e "${RED}Not in a tmux session${NC}"
        exit 1
    fi

    # Create a temporary script for the popup
    local temp_script=$(mktemp)
    cat >"$temp_script" <<EOF
#!/bin/bash
export CHEAT_DIR="$CHEAT_DIR"
$(declare -f check_dependencies build_tree preview_item interactive_browser create_sample_structure)
export -f preview_item
interactive_browser
read -p "Press Enter to close..."
EOF
    chmod +x "$temp_script"

    tmux display-popup -E -w 95% -h 95% -T "📚 Cheatsheet Browser" "$temp_script"
    rm -f "$temp_script"
}

# List all available cheatsheets
list_cheatsheets() {
    echo -e "${BLUE}📚 Available Cheatsheets${NC}"
    echo -e "${CYAN}Directory: $CHEAT_DIR${NC}"
    echo ""

    if command -v tree >/dev/null 2>&1; then
        tree "$CHEAT_DIR" -a --dirsfirst
    else
        find "$CHEAT_DIR" -type f -name "*.md" | sort
    fi
}

# Show specific file
show_file() {
    local query="$1"
    local found_file

    # Search for file by name (case insensitive)
    found_file=$(find "$CHEAT_DIR" -type f -iname "*$query*" | head -1)

    if [[ -z "$found_file" ]]; then
        echo -e "${RED}No cheatsheet found matching: $query${NC}"
        echo -e "${BLUE}Available files:${NC}"
        find "$CHEAT_DIR" -type f -name "*.md" -exec basename {} \; | sort
        return 1
    fi

    echo -e "${GREEN}📋 $(basename "$found_file")${NC}"
    echo -e "${CYAN}$found_file${NC}"
    echo "================================"
    bat "$found_file" \
        --color=always \
        --style=header,grid,numbers \
        --theme=ansi \
        --paging=never 2>/dev/null || cat "$found_file"
}

# Show help
show_help() {
    cat <<EOF
${BLUE}Dynamic Cheatsheet Browser${NC}

${YELLOW}Usage:${NC}
  $0 [command] [options]

${YELLOW}Commands:${NC}
  browse, b                    - Interactive browser (default)
  list, ls                     - List all cheatsheets
  show <query>                 - Show specific cheatsheet
  popup                        - Open in tmux popup
  create                       - Create sample structure
  edit <query>                 - Edit cheatsheet
  help, -h, --help            - Show this help

${YELLOW}Examples:${NC}
  $0                          # Interactive browser
  $0 show docker              # Show docker cheatsheet
  $0 list                     # List all files
  $0 popup                    # Open in tmux popup

${YELLOW}Directory Structure:${NC}
  $CHEAT_DIR/
  ├── docker/
  │   ├── basics.md
  │   └── compose.md
  ├── tmux/
  │   ├── sessions.md
  │   └── panes.md
  └── programming/
      ├── python/
      │   └── basics.md
      └── bash/
          └── basics.md

${YELLOW}FZF Keybindings:${NC}
  Ctrl+R                      - Reload file tree
  Ctrl+E                      - Edit selected file
  Enter                       - View selected file

${YELLOW}Environment:${NC}
  CHEAT_DIR                   - Cheatsheet directory (default: ~/.config/cheatsheets)

EOF
}

# Main function
main() {
    # Set cheatsheet directory
    CHEAT_DIR="${CHEAT_DIR:-$HOME/.config/cheatsheets}"

    case "${1:-browse}" in
    "browse" | "b" | "")
        check_dependencies
        interactive_browser
        ;;
    "list" | "ls")
        list_cheatsheets
        ;;
    "show")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Please specify a cheatsheet to show${NC}"
            exit 1
        fi
        show_file "$2"
        ;;
    "popup")
        check_dependencies
        tmux_popup
        ;;
    "create")
        create_sample_structure
        ;;
    "edit")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Please specify a cheatsheet to edit${NC}"
            exit 1
        fi
        local found_file
        found_file=$(find "$CHEAT_DIR" -type f -iname "*$2*" | head -1)
        if [[ -n "$found_file" ]]; then
            "${EDITOR:-vim}" "$found_file"
        else
            echo -e "${RED}No cheatsheet found matching: $2${NC}"
        fi
        ;;
    "help" | "-h" | "--help")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
    esac
}

main "$@"
