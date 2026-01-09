#!/bin/bash
# Sessions Menu
# Location: ~/.tmux/modules/menus/tmux/sessions-menu.sh

# Use larger popups for session operations
POPUP_WIDTH=90 POPUP_HEIGHT=90
source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#fab387,bold] 󰹬  Sessions  󰹬 " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Navigate ━━━" "" "" \
  "󰹬 Switch Session" s "$(fzf_popup 'session-picker.sh --action=switch')" \
  " Last Session" l "switch-client -l" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Create & Rename ━━━" "" "" \
  " New Session" n "command-prompt -p 'Session name:' 'new-session -d -s %% ; switch-client -t %%'" \
  "󰑕 Rename" r "command-prompt -I '#S' 'rename-session %%'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Control ━━━" "" "" \
  "󰩈 Detach" d "detach-client" \
  "󰒫 Kill Session" x "$(fzf_popup 'session-picker.sh --action=kill')" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Persistence ━━━" "" "" \
  "󰆓 Save State" S "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh' ; display 'Session saved'" \
  "󰦛 Restore" R "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh'" \
  " Last Save" i "display-message 'Last: #(ls -la ~/.tmux/resurrect/last 2>/dev/null | awk \"{print \\$NF}\" || echo \"none\")'"
