#!/usr/bin/env bash
# Preview script for session manager menu

set -euo pipefail

ITEM_ID="$1"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

case "$ITEM_ID" in
    workspace_management)
        cat <<EOF
${BOLD}${CYAN}🌐 Workspace Management${RESET}

${BOLD}Description:${RESET}
  Create, switch, rename, and delete workspaces with
  custom icons, colors, and session persistence.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Create new workspaces with custom icons
  ${GREEN}•${RESET} Set workspace colors for visual organization
  ${GREEN}•${RESET} Auto-save workspace sessions (5-10 min intervals)
  ${GREEN}•${RESET} Load workspace templates
  ${GREEN}•${RESET} Workspace locking (single client per workspace)
  ${GREEN}•${RESET} Neovim AutoSession integration

${BOLD}Operations:${RESET}
  • New Workspace      • Rename Workspace
  • Switch Workspace   • Set Icon/Color
  • Delete Workspace   • Load Template
  • Save Session       • List Sessions
EOF
        ;;

    tab_management)
        cat <<EOF
${BOLD}${CYAN}📑 Tab Management${RESET}

${BOLD}Description:${RESET}
  Manage tabs and tab templates with custom icons,
  colors, and working directory preservation.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Rename tabs with custom icons
  ${GREEN}•${RESET} Save/load tab templates
  ${GREEN}•${RESET} Move tabs between workspaces
  ${GREEN}•${RESET} Grab tabs from other workspaces
  ${GREEN}•${RESET} Custom tab colors
  ${GREEN}•${RESET} Working directory preservation

${BOLD}Operations:${RESET}
  • Rename Tab         • Save Template
  • Set Tab Icon       • Load Template
  • Set Tab Color      • Move to Workspace
  • Clone Tab          • Grab from Workspace
EOF
        ;;

    tab_metadata)
        cat <<EOF
${BOLD}${CYAN}📊 Tab Metadata Browser${RESET}

${BOLD}Description:${RESET}
  Browse and restore tab metadata (titles, icons,
  colors, working directories) with auto-save tracking.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Auto-saved tab metadata on changes
  ${GREEN}•${RESET} Browse all saved tab configurations
  ${GREEN}•${RESET} Filter by workspace
  ${GREEN}•${RESET} View tab creation/update timestamps
  ${GREEN}•${RESET} Preview saved CWD and pane counts
  ${GREEN}•${RESET} Restore tab configurations

${BOLD}Metadata Tracked:${RESET}
  • Tab Title          • Icon
  • Color              • Working Directory
  • Workspace          • Pane Count
  • Last Updated       • Creation Time

${BOLD}Usage:${RESET}
  Opens interactive browser showing saved tabs
  with their metadata and restoration options.
EOF
        ;;

    pane_management)
        cat <<EOF
${BOLD}${CYAN}🪟 Pane Management${RESET}

${BOLD}Description:${RESET}
  Manage terminal panes within tabs with context
  preservation and smart navigation.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Move pane to its own tab
  ${GREEN}•${RESET} Move pane to another tab
  ${GREEN}•${RESET} Grab pane from another tab
  ${GREEN}•${RESET} Working directory preservation
  ${GREEN}•${RESET} Neovim integration for seamless navigation
  ${GREEN}•${RESET} Resize mode with vim-style keys

${BOLD}Operations:${RESET}
  • Move to Own Tab    • Navigate (CTRL+SHIFT+hjkl)
  • Move to Tab        • Resize Mode (LEADER+R)
  • Grab from Tab      • Split Horizontal/Vertical
EOF
        ;;

    tmux_management)
        cat <<EOF
${BOLD}${CYAN}🖥️  TMUX Management${RESET}

${BOLD}Description:${RESET}
  Unified TMUX workspace and session management
  with multi-server support.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Browse TMUX workspaces across servers
  ${GREEN}•${RESET} Attach to existing TMUX sessions
  ${GREEN}•${RESET} Create new TMUX workspaces
  ${GREEN}•${RESET} Multi-server connection management
  ${GREEN}•${RESET} Socket-based workspace isolation
  ${GREEN}•${RESET} Theme browser with TMUX preview

${BOLD}Operations:${RESET}
  • Browse Workspaces  • Switch Server
  • Attach Session     • Theme Browser (Popup)
  • Create Workspace   • List Sessions
  • Manage Servers     • Configure Socket
EOF
        ;;

    tab_color)
        cat <<EOF
${BOLD}${CYAN}🎨 Set Tab Color${RESET}

${BOLD}Description:${RESET}
  Interactive color browser for customizing tab
  colors with live preview.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Curated color palette (Catppuccin + more)
  ${GREEN}•${RESET} Live preview of tab appearance
  ${GREEN}•${RESET} Color persistence across sessions
  ${GREEN}•${RESET} Clear color to use default
  ${GREEN}•${RESET} TMUX workspace color awareness
  ${GREEN}•${RESET} Searchable color names

${BOLD}Usage:${RESET}
  Opens interactive fzf browser showing:
  • Color name, hex value, and description
  • Live preview of tab with selected color
  • Current tab title and icon
  • Alt-C to clear custom color
EOF
        ;;

    keymaps)
        cat <<EOF
${BOLD}${CYAN}⌨️  Keymaps${RESET}

${BOLD}Description:${RESET}
  Interactive keyboard shortcut browser with
  searchable bindings organized by modifier.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} Search all keybindings by action
  ${GREEN}•${RESET} Organized by modifier keys
  ${GREEN}•${RESET} Shows action descriptions
  ${GREEN}•${RESET} Leader key bindings (SUPER+Space)
  ${GREEN}•${RESET} Copy mode bindings
  ${GREEN}•${RESET} Key table modes (resize, search, etc.)

${BOLD}Sections:${RESET}
  • LEADER Mode        • SUPER Mode
  • CTRL Mode          • ALT Mode
  • Copy Mode          • Search Mode
  • Resize Mode        • Pane Selection
EOF
        ;;

    themes)
        cat <<EOF
${BOLD}${CYAN}🎨 Themes${RESET}

${BOLD}Description:${RESET}
  Browse and preview WezTerm color themes with
  live preview and workspace persistence.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} 500+ built-in color themes
  ${GREEN}•${RESET} Live preview as you browse
  ${GREEN}•${RESET} Workspace-specific theme saving
  ${GREEN}•${RESET} Filter by light/dark, temperature
  ${GREEN}•${RESET} Backdrop opacity adjustment
  ${GREEN}•${RESET} Two preview modes: standard & popup

${BOLD}Preview Modes:${RESET}
  • Standard Browser   - Full-screen fzf with live preview
  • Popup Browser      - TMUX popup with split preview

${BOLD}Controls:${RESET}
  ↑↓: Navigate themes  | Enter: Apply theme
  +/-: Adjust opacity  | /: Toggle preview
EOF
        ;;

    nerdfont_picker)
        cat <<EOF
${BOLD}${CYAN}🔤 Nerdfont Picker${RESET}

${BOLD}Description:${RESET}
  Browse and select Nerd Fonts icons with
  searchable categories and clipboard integration.

${BOLD}Features:${RESET}
  ${GREEN}•${RESET} 3000+ Nerd Fonts icons
  ${GREEN}•${RESET} Searchable by name and category
  ${GREEN}•${RESET} Copy icons to clipboard
  ${GREEN}•${RESET} Preview icon rendering
  ${GREEN}•${RESET} Categorized icon sets
  ${GREEN}•${RESET} Unicode codepoint display

${BOLD}Categories:${RESET}
  • Dev Icons          • Font Awesome
  • Material Design    • Weather Icons
  • Octicons           • Powerline
  • File Icons         • Linux Logos
  • Custom Symbols     • And more...

${BOLD}Usage:${RESET}
  Search, select, and the icon is copied to clipboard
  for use in tab names, prompts, or any text.
EOF
        ;;

    *)
        echo "No preview available"
        ;;
esac
