#!/bin/bash
# File: tmux-nerd-integration.sh
# Function: Tmux key bindings and integration for the Nerd Font browser system

# Add these bindings to your ~/.tmux.conf file:

# Key binding to open Nerd Font browser
# bind-key 'n' run-shell "~/scripts/nerd-font-browser.sh"

# Quick access to specific categories via prefix + key combinations
# bind-key 'N' display-menu -T "Nerd Font Categories" \
#   "Angles & Arrows" "a" "run-shell '~/scripts/nerd-font-browser.sh \"Angles & Arrows\"'" \
#   "Blocks & Shapes" "b" "run-shell '~/scripts/nerd-font-browser.sh \"Blocks & Shapes\"'" \
#   "Brackets & Braces" "r" "run-shell '~/scripts/nerd-font-browser.sh \"Brackets & Braces\"'" \
#   "Circular Icons" "c" "run-shell '~/scripts/nerd-font-browser.sh \"Circular Icons\"'" \
#   "Diamond Shapes" "d" "run-shell '~/scripts/nerd-font-browser.sh \"Diamond Shapes\"'" \
#   "GitHub & Git" "g" "run-shell '~/scripts/nerd-font-browser.sh \"GitHub & Git\"'" \
#   "General Icons" "i" "run-shell '~/scripts/nerd-font-browser.sh \"General Icons\"'" \
#   "Lines & Borders" "l" "run-shell '~/scripts/nerd-font-browser.sh \"Lines & Borders\"'" \
#   "Powerline Symbols" "p" "run-shell '~/scripts/nerd-font-browser.sh \"Powerline Symbols\"'" \
#   "Square Shapes" "s" "run-shell '~/scripts/nerd-font-browser.sh \"Square Shapes\"'"

# Function to set up tmux integration
setup_tmux_integration() {
    local tmux_conf="$HOME/tmux.conf"
    local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nerd-font-browser.sh"

    echo "Setting up tmux integration..."

    # Backup existing tmux.conf if it exists
    if [[ -f "$tmux_conf" ]]; then
        cp "$tmux_conf" "$tmux_conf.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backed up existing tmux.conf"
    fi

    # Add Nerd Font browser bindings
    cat >>"$tmux_conf" <<EOF

# Nerd Font Browser Integration
# Quick access to Nerd Font icon browser
bind-key 'n' run-shell "$script_path"

# Category-specific quick access menu
bind-key 'N' display-menu -T "Nerd Font Categories" \\
  "Angles & Arrows" "a" "run-shell '$script_path \"Angles & Arrows\"'" \\
  "Blocks & Shapes" "b" "run-shell '$script_path \"Blocks & Shapes\"'" \\
  "Brackets & Braces" "r" "run-shell '$script_path \"Brackets & Braces\"'" \\
  "Circular Icons" "c" "run-shell '$script_path \"Circular Icons\"'" \\
  "Diamond Shapes" "d" "run-shell '$script_path \"Diamond Shapes\"'" \\
  "GitHub & Git" "g" "run-shell '$script_path \"GitHub & Git\"'" \\
  "General Icons" "i" "run-shell '$script_path \"General Icons\"'" \\
  "Lines & Borders" "l" "run-shell '$script_path \"Lines & Borders\"'" \\
  "Powerline Symbols" "p" "run-shell '$script_path \"Powerline Symbols\"'" \\
  "Square Shapes" "s" "run-shell '$script_path \"Square Shapes\"'"

# Insert selected icon directly into current pane
bind-key 'I' run-shell "$script_path | tmux send-keys -t #{pane_id}"

EOF

    echo "Added Nerd Font browser bindings to $tmux_conf"
    echo ""
    echo "Key bindings added:"
    echo "  Prefix + n  : Open Nerd Font browser"
    echo "  Prefix + N  : Quick category menu"
    echo "  Prefix + I  : Insert icon directly into current pane"
    echo ""
    echo "Reload tmux config with: tmux source-file ~/.tmux.conf"
}

# Function to create a combined all-icons file for the original fzf script
create_combined_file() {
    local output_file="/tmp/nerd-fonts-all.txt"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    echo "Creating combined Nerd Font file at $output_file..."

    # Header
    {
        echo "# Combined Nerd Font Icons"
        echo "# Generated: $(date)"
        echo ""
    } >"$output_file"

    # Combine all category files
    for category_file in nerd-*.sh; do
        if [[ -f "$script_dir/$category_file" ]]; then
            echo "# Category: $(basename "$category_file" .sh)" >>"$output_file"
            grep -v '^#' "$script_dir/$category_file" | grep -v '^$' >>"$output_file"
            echo "" >>"$output_file"
        fi
    done

    echo "Combined file created with $(grep -v '^#' "$output_file" | grep -v '^$' | wc -l) icons"
}

# Function to test the system
test_browser() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    echo "Testing Nerd Font browser system..."
    echo "Script directory: $script_dir"
    echo ""

    # Check for required files
    local missing_files=()
    for file in nerd-angle.sh nerd-blocks.sh nerd-bracks.sh nerd-cirtcular.sh nerd-diamond.sh nerd-github.sh nerd-icons.sh nerd-lines.sh nerd-powerline.sh nerd-square.sh; do
        if [[ ! -f "$script_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo "Missing category files:"
        printf "  %s\n" "${missing_files[@]}"
        echo ""
    else
        echo "All category files found ✓"
    fi

    # Check for required tools
    local missing_tools=()
    for tool in fzf bat; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "Missing required tools:"
        printf "  %s\n" "${missing_tools[@]}"
        echo ""
        echo "Install with:"
        echo "  sudo apt install fzf bat  # Debian/Ubuntu"
        echo "  brew install fzf bat     # macOS"
        echo "  sudo pacman -S fzf bat   # Arch"
    else
        echo "All required tools found ✓"
    fi

    # Check tmux
    if [[ -n "$TMUX" ]]; then
        echo "Running in tmux ✓"
    else
        echo "Not in tmux session (popups won't work)"
    fi

    echo ""
    echo "Run '$script_dir/nerd-font-browser.sh' to test the browser"
}

# Main function
main() {
    case "$1" in
    "setup")
        setup_tmux_integration
        ;;
    "combine")
        create_combined_file
        ;;
    "test")
        test_browser
        ;;
    *)
        echo "Usage: $0 {setup|combine|test}"
        echo ""
        echo "Commands:"
        echo "  setup   - Add tmux key bindings to ~/.tmux.conf"
        echo "  combine - Create combined icon file for original fzf script"
        echo "  test    - Test the browser system setup"
        ;;
    esac
}

main "$@"
