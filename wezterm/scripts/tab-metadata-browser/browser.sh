#!/usr/bin/env bash
# Tab Metadata Browser with FZF

set -euo pipefail

WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.core/.sys/cfg/wezterm}"
METADATA_FILE="$WEZTERM_CONFIG_DIR/.data/tabs/metadata.json"
TEMPLATES_FILE="$WEZTERM_CONFIG_DIR/.data/tabs/templates.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_SCRIPT="$SCRIPT_DIR/preview.sh"

# Ensure dependencies
for cmd in fzf jq; do
	if ! command -v "$cmd" &>/dev/null; then
		echo "Error: $cmd is not installed" >&2
		exit 1
	fi
done

# Make preview script executable
chmod +x "$PREVIEW_SCRIPT"

# Check if metadata file exists
if [[ ! -f "$METADATA_FILE" ]]; then
	echo "No tab metadata found at: $METADATA_FILE"
	echo ""
	echo "Tab metadata is auto-captured when you:"
	echo "  - Rename a tab"
	echo "  - Change tab color"
	echo "  - Change tab icon"
	echo ""
	echo "Try renaming a tab first, then run this browser again."
	exit 1
fi

# Count tabs and templates
TAB_COUNT=$(jq 'length' "$METADATA_FILE" 2>/dev/null || echo "0")
TEMPLATE_COUNT=0
if [[ -f "$TEMPLATES_FILE" ]]; then
	TEMPLATE_COUNT=$(jq 'length' "$TEMPLATES_FILE" 2>/dev/null || echo "0")
fi

if [[ "$TAB_COUNT" -eq 0 ]] && [[ "$TEMPLATE_COUNT" -eq 0 ]]; then
	echo "No tabs or templates with metadata found"
	exit 1
fi

# Format combined list for fzf
format_combined_list() {
	# Section 1: Active Tabs
	if [[ "$TAB_COUNT" -gt 0 ]]; then
		echo "━━━ ACTIVE TABS ($TAB_COUNT) ━━━"
		jq -r 'to_entries[] |
			"tab:\(.key)|\(.value.icon // "")|\(.value.title // "Untitled")|\(.value.color // "none")|\(.value.workspace // "default")|\(.value.pane_count // 0)|\(.value.cwd // "unknown")"' \
			"$METADATA_FILE" |
		while IFS='|' read -r tab_id icon title color workspace panes cwd; do
			# Truncate long paths
			short_cwd=$(echo "$cwd" | sed "s|$HOME|~|" | awk '{if(length($0)>30) print substr($0,1,27)"..."; else print}')

			# Color indicator
			color_display="$color"
			if [[ "$color" != "none" ]]; then
				color_display="●"
			fi

			# Format: TabID  Icon Title  [Color] Workspace (Panes) CWD
			printf "%-12s  %s%-20s  [%-6s] %-12s (%d) %s\n" \
				"$tab_id" \
				"${icon:+$icon }" \
				"$title" \
				"$color_display" \
				"$workspace" \
				"$panes" \
				"$short_cwd"
		done
	fi

	# Section 2: Saved Templates
	if [[ "$TEMPLATE_COUNT" -gt 0 ]]; then
		echo ""
		echo "━━━ SAVED TEMPLATES ($TEMPLATE_COUNT) ━━━"
		jq -r 'to_entries[] |
			"template:\(.key)|\(.value.icon // "")|\(.value.title // .key)|\(.value.color // "none")|\(.value.created_at // "unknown")"' \
			"$TEMPLATES_FILE" |
		while IFS='|' read -r template_id icon title color created_at; do
			# Color indicator
			color_display="$color"
			if [[ "$color" != "none" ]]; then
				color_display="●"
			fi

			# Format: TemplateID  Icon Title  [Color] Created
			printf "%-12s  %s%-20s  [%-6s] %s\n" \
				"$template_id" \
				"${icon:+$icon }" \
				"$title" \
				"$color_display" \
				"$created_at"
		done
	fi
}

# Launch fzf browser
selected=$(format_combined_list | \
	fzf \
		--ansi \
		--height=100% \
		--layout=reverse \
		--border=rounded \
		--border-label="╣ Tab Metadata Browser ($TAB_COUNT tabs, $TEMPLATE_COUNT templates) ╠" \
		--prompt="Tab ❯ " \
		--pointer="▶" \
		--marker="✓" \
		--header=$'Navigate: ↑↓ | Preview: → | Capture All: Ctrl-A | Quit: Esc\n─────────────────────────────────────────────────────────────────────' \
		--preview="$PREVIEW_SCRIPT {1}" \
		--preview-window=right:60%:wrap:rounded \
		--color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
		--color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
		--color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
		--color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
		--bind="ctrl-/:toggle-preview" \
		--bind="ctrl-a:execute(echo 'Capturing all tabs...' && wezterm cli list 2>&1 >/dev/null)+reload($0)")

# Extract tab ID from selection
if [[ -n "$selected" ]]; then
	tab_id=$(echo "$selected" | awk '{print $1}')
	echo "Selected tab: $tab_id"

	# Could add actions here (switch to tab, etc.)
fi
