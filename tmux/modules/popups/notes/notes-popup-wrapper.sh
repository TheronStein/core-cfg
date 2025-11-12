#!/usr/bin/env bash
TMUX_POPUP=1 exec "$HOME/.config/tmux/scripts/notes-popup.sh"

# Check if we're in a popup
# if [ -n "$TMUX_POPUP" ]; then
#     # Switch to notes-popup key table within the popup
#     tmux switch-client -T notes-popup
#
#     # Show a brief help message
#     tmux display-message -d 2000 "Notes popup active. Press ? for help"
# fi
#
# # Run the actual notes script
# exec "$HOME/.config/tmux/scripts/notes-popup.sh"
