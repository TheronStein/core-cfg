#!/usr/bin/env bash
# Yazibar - Interactive Settings
# fzf-based configuration popup for runtime settings

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# OPTION DEFINITIONS
# ============================================================================

# Get current option states
get_option_state() {
    local option="$1"
    local value=$(get_tmux_option "$option" "0")
    [ "$value" = "1" ] && echo "[x]" || echo "[ ]"
}

# Toggle a tmux option
toggle_option() {
    local option="$1"
    local current=$(get_tmux_option "$option" "0")
    if [ "$current" = "1" ]; then
        set_tmux_option "$option" "0"
        echo "Disabled: $option"
    else
        set_tmux_option "$option" "1"
        echo "Enabled: $option"
    fi
}

# ============================================================================
# MENU GENERATION
# ============================================================================

generate_menu() {
    local toggle_both=$(get_option_state "@yazibar-toggle-both")
    local smart_split=$(get_option_state "@yazibar-smart-split")
    local debug=$(get_option_state "@yazibar-debug")
    local right_needs_left=$(get_option_state "@yazibar-right-needs-left")

    cat <<EOF
$toggle_both Toggle Both Mode         (@yazibar-toggle-both)
$smart_split Smart Split              (@yazibar-smart-split)
$right_needs_left Right Needs Left         (@yazibar-right-needs-left)
$debug Debug Logging            (@yazibar-debug)
---
    Save Current Widths      (persist to disk)
    Reset Width Defaults     (clear saved widths)
    Show Status              (display current state)
    View Debug Log           (open debug.log)
EOF
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

handle_selection() {
    local selection="$1"

    case "$selection" in
        *"Toggle Both Mode"*)
            toggle_option "@yazibar-toggle-both"
            ;;
        *"Smart Split"*)
            toggle_option "@yazibar-smart-split"
            ;;
        *"Right Needs Left"*)
            toggle_option "@yazibar-right-needs-left"
            ;;
        *"Debug Logging"*)
            toggle_option "@yazibar-debug"
            ;;
        *"Save Current Widths"*)
            "$SCRIPT_DIR/yazibar-width.sh" auto-save
            echo "Widths saved"
            ;;
        *"Reset Width Defaults"*)
            rm -f "$YAZIBAR_WIDTH_FILE"
            echo "Width cache cleared"
            ;;
        *"Show Status"*)
            show_full_status
            return 0
            ;;
        *"View Debug Log"*)
            view_debug_log
            return 0
            ;;
        *)
            return 1
            ;;
    esac

    # Small delay to show feedback
    sleep 0.3
}

# ============================================================================
# STATUS DISPLAY
# ============================================================================

show_full_status() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    YAZIBAR STATUS                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    echo "=== Configuration ==="
    echo "Toggle Both:       $(get_tmux_option "@yazibar-toggle-both" "1")"
    echo "Smart Split:       $(get_tmux_option "@yazibar-smart-split" "0")"
    echo "Right Needs Left:  $(get_tmux_option "@yazibar-right-needs-left" "1")"
    echo "Debug:             $(get_tmux_option "@yazibar-debug" "0")"
    echo ""

    echo "=== Left Sidebar ==="
    "$SCRIPT_DIR/yazibar-left.sh" status 2>/dev/null | tail -n +2
    echo ""

    echo "=== Right Sidebar ==="
    "$SCRIPT_DIR/yazibar-right.sh" status 2>/dev/null | tail -n +2
    echo ""

    echo "=== Default Widths ==="
    echo "Left:  $(yazibar_left_width)"
    echo "Right: $(yazibar_right_width)"
    echo ""

    if [ -f "$YAZIBAR_WIDTH_FILE" ]; then
        echo "=== Saved Widths ==="
        cat "$YAZIBAR_WIDTH_FILE" | head -10
        local count=$(wc -l < "$YAZIBAR_WIDTH_FILE")
        if [ "$count" -gt 10 ]; then
            echo "... and $((count - 10)) more entries"
        fi
    fi

    echo ""
    read -p "Press Enter to continue..."
}

view_debug_log() {
    local log_file="$YAZIBAR_DATA_DIR/debug.log"

    if [ ! -f "$log_file" ]; then
        echo "No debug log found."
        echo "Enable debug mode first: set @yazibar-debug to 1"
        read -p "Press Enter to continue..."
        return
    fi

    # Use less if available, otherwise cat
    if command -v less &>/dev/null; then
        less +G "$log_file"
    else
        tail -100 "$log_file"
        read -p "Press Enter to continue..."
    fi
}

# ============================================================================
# FZF POPUP INTERFACE
# ============================================================================

run_popup() {
    # Check for fzf
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for interactive settings"
        echo "Install with: pacman -S fzf"
        read -p "Press Enter to continue..."
        return 1
    fi

    while true; do
        local selection=$(generate_menu | fzf \
            --header="Yazibar Settings (ESC to exit)" \
            --header-first \
            --reverse \
            --no-info \
            --height=100% \
            --border=rounded \
            --prompt="  " \
            --pointer=">" \
            --color="header:bold,pointer:cyan,prompt:cyan" \
            --bind="enter:accept" \
            --bind="q:abort" \
            --bind="esc:abort")

        # Exit if nothing selected or user pressed ESC
        [ -z "$selection" ] && break

        # Skip separator lines
        [[ "$selection" == "---" ]] && continue

        # Handle the selection
        handle_selection "$selection"
    done
}

# ============================================================================
# SIMPLE CLI INTERFACE
# ============================================================================

show_options() {
    echo "Yazibar Options:"
    echo ""
    echo "  @yazibar-toggle-both        = $(get_tmux_option "@yazibar-toggle-both" "0")"
    echo "  @yazibar-smart-split        = $(get_tmux_option "@yazibar-smart-split" "0")"
    echo "  @yazibar-bidirectional-sync = $(get_tmux_option "@yazibar-bidirectional-sync" "1")"
    echo "  @yazibar-right-needs-left   = $(get_tmux_option "@yazibar-right-needs-left" "1")"
    echo "  @yazibar-debug              = $(get_tmux_option "@yazibar-debug" "0")"
    echo ""
    echo "Use 'yazibar-settings.sh set <option> <0|1>' to change"
}

set_option() {
    local option="$1"
    local value="$2"

    if [ -z "$option" ] || [ -z "$value" ]; then
        echo "Usage: yazibar-settings.sh set <option> <0|1>"
        return 1
    fi

    # Add @ prefix if missing
    [[ "$option" != @* ]] && option="@$option"

    set_tmux_option "$option" "$value"
    echo "Set $option = $value"
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-popup}" in
    popup)
        run_popup
        ;;
    status)
        show_full_status
        ;;
    options|list)
        show_options
        ;;
    set)
        set_option "$2" "$3"
        ;;
    toggle)
        toggle_option "$2"
        ;;
    help|*)
        cat <<EOF
Yazibar Settings Manager

COMMANDS:
  popup               Interactive fzf settings menu (default)
  status              Show full status information
  options             List current option values
  set <opt> <0|1>     Set an option value
  toggle <opt>        Toggle an option

OPTIONS:
  @yazibar-toggle-both        Enable toggle-both mode
  @yazibar-smart-split        Auto-detect optimal split direction
  @yazibar-bidirectional-sync Enable two-way navigation sync
  @yazibar-right-needs-left   Right sidebar requires left
  @yazibar-debug              Enable debug logging

USAGE:
  $0 popup                                    # Open interactive menu
  $0 set @yazibar-smart-split 1               # Enable smart split
  $0 toggle @yazibar-debug                    # Toggle debug mode
EOF
        ;;
esac
