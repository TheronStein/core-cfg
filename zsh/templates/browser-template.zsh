#!/usr/bin/env zsh
# Browser Template - Copy this to create new browsers
# Replace TEMPLATE with your browser name (e.g., bookmarks, configs, docs)

#=============================================================================
# BROWSER: TEMPLATE
# Description: [Brief description of what this browser does]
# Data location: $BROWSER_DATA_DIR/TEMPLATE/
# Dependencies: [List required commands: fzf, jq, etc.]
#=============================================================================

#-----------------------------------------------------------------------------
# Data Generator Function
#-----------------------------------------------------------------------------
# Function: data::generate::TEMPLATE
# Description: Generates the data file(s) for this browser
# Called automatically if data file doesn't exist
# Should be idempotent (safe to run multiple times)
#-----------------------------------------------------------------------------
data::generate::TEMPLATE() {
  local data_dir="$BROWSER_DATA_DIR/TEMPLATE"
  mkdir -p "$data_dir"

  # Example: Generate a simple text file
  cat > "$data_dir/data.txt" <<'EOF'
# TEMPLATE Data
# One entry per line
# Comments start with #

entry1    Description of entry 1
entry2    Description of entry 2
entry3    Description of entry 3
EOF

  # Example: Generate a JSON file (if using structured data)
  # cat > "$data_dir/data.json" <<'EOF'
  # {
  #   "items": [
  #     {
  #       "name": "Item 1",
  #       "value": "value1",
  #       "description": "Description 1"
  #     }
  #   ]
  # }
  # EOF

  echo "TEMPLATE data generated in $data_dir" >&2
  return 0
}

#-----------------------------------------------------------------------------
# Data Loader Function
#-----------------------------------------------------------------------------
# Function: data::load::TEMPLATE
# Description: Loads and formats data for fzf display
# Output: One line per selectable item
# Format: Use consistent column formatting for readability
#-----------------------------------------------------------------------------
data::load::TEMPLATE() {
  local data_file="$BROWSER_DATA_DIR/TEMPLATE/data.txt"

  # Simple text file - filter comments and empty lines
  grep -v '^#' "$data_file" | grep -v '^[[:space:]]*$'

  # JSON example (if using jq):
  # local data_file="$BROWSER_DATA_DIR/TEMPLATE/data.json"
  # if (( $+commands[jq] )); then
  #   jq -r '.items[] | "\(.name)|\(.value)|\(.description)"' "$data_file" | \
  #     while IFS='|' read -r name value desc; do
  #       printf "%-20s  %-30s  %s\n" "$name" "$value" "$desc"
  #     done
  # else
  #   echo "jq required for TEMPLATE browser" >&2
  #   return 1
  # fi
}

#-----------------------------------------------------------------------------
# Preview Function
#-----------------------------------------------------------------------------
# Function: preview::TEMPLATE
# Description: Generates preview content for selected item
# Input: $1 - The selected line from fzf
# Output: Preview text (can be multi-line, can use colors/formatting)
#-----------------------------------------------------------------------------
preview::TEMPLATE() {
  local selection="$1"
  local item_name=$(echo "$selection" | awk '{print $1}')

  # Simple preview
  echo "Selected: $item_name"
  echo ""
  echo "Details about: $selection"

  # Advanced preview - lookup details from data file
  # local data_file="$BROWSER_DATA_DIR/TEMPLATE/data.json"
  # if (( $+commands[jq] )); then
  #   jq -r --arg name "$item_name" \
  #     '.items[] | select(.name == $name) |
  #      "Name: \(.name)\nValue: \(.value)\nDescription: \(.description)"' \
  #     "$data_file"
  # fi

  # Preview with syntax highlighting (if previewing code/config)
  # bat --style=plain --color=always "$file_path"
}

#-----------------------------------------------------------------------------
# Action Handler Function
#-----------------------------------------------------------------------------
# Function: action::TEMPLATE
# Description: Handles what happens when user selects an item
# Input: $1 - The selected line from fzf
# Actions: Can copy, execute, open editor, etc.
#-----------------------------------------------------------------------------
action::TEMPLATE() {
  local selection="$1"
  local item=$(echo "$selection" | awk '{print $1}')

  # Example actions:

  # 1. Copy to clipboard
  # if (( $+commands[wl-copy] )); then
  #   echo -n "$item" | wl-copy
  #   echo "Copied to clipboard: $item" >&2
  # fi

  # 2. Execute command
  # eval "$item"

  # 3. Open in editor
  # ${EDITOR:-nvim} "$item"

  # 4. Insert into command line (handled by widget wrapper)
  # echo "$item"

  # 5. Custom action
  echo "Selected: $item"
}

#-----------------------------------------------------------------------------
# Main Browser Function
#-----------------------------------------------------------------------------
# Function: browser::TEMPLATE
# Description: Main entry point for the browser
# This orchestrates the entire browser flow
#-----------------------------------------------------------------------------
browser::TEMPLATE() {
  # Define data file location
  local data_file="$BROWSER_DATA_DIR/TEMPLATE/data.txt"

  # Ensure data exists (generates if missing)
  data::ensure TEMPLATE "$data_file" || return 1

  # Option 1: Use browser::base helper (recommended for simple browsers)
  browser::base \
    "TEMPLATE" \
    "data::load::TEMPLATE" \
    "preview::TEMPLATE {}" \
    "Select item | Ctrl+/: toggle preview | Enter: confirm" \
    "action::TEMPLATE"

  # Option 2: Custom implementation (for complex behaviors)
  # local selection
  # selection=$(data::load::TEMPLATE | \
  #   fzf $(_fzf_base_opts) \
  #     --height=100% \
  #     --prompt="TEMPLATE ❯ " \
  #     --header="Select item" \
  #     --preview='preview::TEMPLATE {}' \
  #     --preview-window='right:60%:wrap' \
  #     --bind='ctrl-r:reload(data::load::TEMPLATE)' \
  #     --bind='ctrl-e:execute(${EDITOR:-nvim} {})' )
  #
  # [[ -z "$selection" ]] && return 0
  # action::TEMPLATE "$selection"
}

#-----------------------------------------------------------------------------
# Widget Wrapper (for ZLE integration)
#-----------------------------------------------------------------------------
# Function: widget::TEMPLATE
# Description: Makes browser work as a ZLE widget
# Keybinding: Add to your config: bindkey '^X^T' widget::TEMPLATE
#-----------------------------------------------------------------------------
widget::TEMPLATE() {
  # Options for insert_mode:
  #   'insert' - Insert result into command line
  #   'execute' - Execute result as command
  #   'none' - Browser has side effects (copy, open editor, etc.)

  browser::widget browser::TEMPLATE none

  # Alternative: Insert result into command line
  # browser::widget browser::TEMPLATE insert

  # Alternative: Execute result as command
  # browser::widget browser::TEMPLATE execute
}

# Register as widget (uncomment to activate)
# zle -N widget::TEMPLATE
# bindkey '^X^T' widget::TEMPLATE  # Ctrl+X Ctrl+T

#=============================================================================
# ADVANCED FEATURES (optional)
#=============================================================================

# Multi-select browser variant
browser::TEMPLATE::multi() {
  local data_file="$BROWSER_DATA_DIR/TEMPLATE/data.txt"
  data::ensure TEMPLATE "$data_file" || return 1

  browser::multi \
    "TEMPLATE" \
    "data::load::TEMPLATE" \
    "preview::TEMPLATE {}" \
    "Select items (Tab for multi-select) | Ctrl+A: select all" \
    "action::TEMPLATE"
}

# Update/refresh data
browser::TEMPLATE::update() {
  echo "Updating TEMPLATE data..."
  data::generate::TEMPLATE
  echo "Update complete!"
}

# Show browser help
browser::TEMPLATE::help() {
  cat <<'HELP'
TEMPLATE Browser

Usage:
  browser::TEMPLATE              Run the browser
  browser::TEMPLATE::multi       Multi-select mode
  browser::TEMPLATE::update      Refresh data

Keybindings (in browser):
  Enter        - Confirm selection
  Esc          - Cancel
  Ctrl+/       - Toggle preview
  Ctrl+A       - Select all (multi-select mode)
  Ctrl+D       - Deselect all (multi-select mode)
  Tab          - Select item and move down (multi-select mode)

Integration:
  Shell:    browser::TEMPLATE
  Widget:   Ctrl+X Ctrl+T (if bound)
  Tmux:     bind-key T run-shell "zsh -ic 'browser::TEMPLATE'"
  Wezterm:  spawn({ args = { 'zsh', '-ic', 'browser::TEMPLATE' } })

Data Location:
  $BROWSER_DATA_DIR/TEMPLATE/

Dependencies:
  Required: fzf
  Optional: jq (for JSON data), bat (for previews)
HELP
}

#=============================================================================
# CUSTOMIZATION CHECKLIST
#=============================================================================
#
# When creating a new browser from this template:
#
# 1. [ ] Replace all TEMPLATE with your browser name
# 2. [ ] Update description and dependencies at top
# 3. [ ] Implement data::generate::NAME to create data files
# 4. [ ] Implement data::load::NAME to format data for fzf
# 5. [ ] Implement preview::NAME for rich preview content
# 6. [ ] Implement action::NAME for selection handling
# 7. [ ] Update browser::NAME if custom behavior needed
# 8. [ ] Choose widget insert mode (insert/execute/none)
# 9. [ ] Update keybinding suggestion
# 10. [ ] Update help text with browser-specific info
# 11. [ ] Add to integrations/browsers.zsh or source separately
# 12. [ ] Test browser in shell, as widget, from tmux/wezterm
# 13. [ ] Update documentation
# 14. [ ] Add to browser::list() function
#
#=============================================================================

# vim: ft=zsh:et:sw=2:ts=2:sts=2:fdm=marker:fmr={{{,}}}
