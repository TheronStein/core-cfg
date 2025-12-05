#!/usr/bin/env bash
# Tab Metadata Preview Script

set -euo pipefail

WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.core/.sys/cfg/wezterm}"
METADATA_FILE="$WEZTERM_CONFIG_DIR/.data/tabs/metadata.json"
TEMPLATES_FILE="$WEZTERM_CONFIG_DIR/.data/tabs/templates.json"

preview_tab() {
	local tab_id="$1"

	if [[ ! -f "$METADATA_FILE" ]]; then
		echo "No metadata file found"
		return 1
	fi

	local tab_data=$(jq -r --arg id "$tab_id" '.[$id]' "$METADATA_FILE")

	if [[ "$tab_data" == "null" ]]; then
		echo "No metadata for tab $tab_id"
		return 1
	fi

	# Extract fields
	local title=$(echo "$tab_data" | jq -r '.title // "Untitled"')
	local icon=$(echo "$tab_data" | jq -r '.icon // ""')
	local color=$(echo "$tab_data" | jq -r '.color // "none"')
	local cwd=$(echo "$tab_data" | jq -r '.cwd // "unknown"')
	local workspace=$(echo "$tab_data" | jq -r '.workspace // "default"')
	local pane_count=$(echo "$tab_data" | jq -r '.pane_count // 0')
	local updated_at=$(echo "$tab_data" | jq -r '.updated_at // "never"')

	# Display formatted preview
	cat <<-EOF
		╭─────────────────────────────────────────╮
		│           TAB METADATA                  │
		╰─────────────────────────────────────────╯

		🆔  Tab ID:       $tab_id
		📝  Title:        ${icon:+$icon }$title
		🎨  Color:        $color
		📁  CWD:          $cwd
		🌐  Workspace:    $workspace
		📊  Pane Count:   $pane_count
		🕒  Updated:      $updated_at

		╭─────────────────────────────────────────╮
		│       CWD CONTENTS (ls -la)             │
		╰─────────────────────────────────────────╯

	EOF

	# Show directory contents if CWD exists
	if [[ -d "$cwd" ]]; then
		ls -lah --color=always "$cwd" 2>/dev/null | head -20
	else
		echo "  Directory not accessible or doesn't exist"
	fi
}

preview_template() {
	local template_id="$1"

	if [[ ! -f "$TEMPLATES_FILE" ]]; then
		echo "No templates file found"
		return 1
	fi

	local template_data=$(jq -r --arg id "$template_id" '.[$id]' "$TEMPLATES_FILE")

	if [[ "$template_data" == "null" ]]; then
		echo "No template found: $template_id"
		return 1
	fi

	# Extract fields
	local title=$(echo "$template_data" | jq -r '.title // .name // "Untitled"')
	local full_title=$(echo "$template_data" | jq -r '.full_title // .title // ""')
	local icon=$(echo "$template_data" | jq -r '.icon // ""')
	local color=$(echo "$template_data" | jq -r '.color // "none"')
	local created_at=$(echo "$template_data" | jq -r '.created_at // "unknown"')
	local cwd=$(echo "$template_data" | jq -r '.cwd // ""')
	local tmux_session=$(echo "$template_data" | jq -r '.tmux_session // ""')

	# Display formatted preview
	cat <<-EOF
		╭─────────────────────────────────────────╮
		│        SAVED TEMPLATE                   │
		╰─────────────────────────────────────────╯

		🆔  Template:     $template_id
		📝  Title:        $full_title
		🎨  Color:        $color
		🕒  Created:      $created_at
	EOF

	# Optional fields
	if [[ -n "$cwd" ]]; then
		echo "	📁  Saved CWD:    $cwd"
	fi
	if [[ -n "$tmux_session" ]]; then
		echo "	  Tmux:         $tmux_session"
	fi

	cat <<-EOF

		╭─────────────────────────────────────────╮
		│         TEMPLATE DETAILS                │
		╰─────────────────────────────────────────╯

		This is a saved tab template that can be
		applied to new tabs to restore the saved
		configuration (title, icon, color).

		Use the session manager (LEADER+F1) to
		apply this template to a tab.
	EOF
}

# Main
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 <id>"
	exit 1
fi

# Detect if this is a tab or template based on prefix
ID="$1"

if [[ "$ID" == tab:* ]]; then
	# Strip "tab:" prefix and preview as active tab
	preview_tab "${ID#tab:}"
elif [[ "$ID" == template:* ]]; then
	# Strip "template:" prefix and preview as template
	preview_template "${ID#template:}"
else
	# Fallback: try as tab first, then template
	if preview_tab "$ID" 2>/dev/null; then
		exit 0
	else
		preview_template "$ID"
	fi
fi
