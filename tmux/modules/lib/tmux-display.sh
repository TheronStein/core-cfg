#!/usr/bin/env bash
# modules/lib/tmux-display.sh
# Display and messaging functions
#
# Provides functions for displaying messages, errors, info, and success
# notifications in tmux with appropriate styling and durations.

# Source core library for option management
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tmux-core.sh"

display_message() {
    local message="$1"
    local duration="${2:-3000}"

    # Save current display-time
    local saved_duration
    saved_duration=$(get_tmux_option "display-time" "750")

    # Set temporary display time
    tmux set-option -gq display-time "$duration"

    # Display message
    tmux display-message "$message"

    # Restore original display time
    tmux set-option -gq display-time "$saved_duration"
}

display_error() {
    local message="$1"
    display_message "#[fg=red]ERROR: $message" 5000
}

display_info() {
    local message="$1"
    display_message "#[fg=blue]INFO: $message" 2000
}

display_success() {
    local message="$1"
    display_message "#[fg=green]SUCCESS: $message" 2000
}

display_warning() {
    local message="$1"
    display_message "#[fg=yellow]WARNING: $message" 3000
}

# Export functions
export -f display_message display_error display_info display_success display_warning
