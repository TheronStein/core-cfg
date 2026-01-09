#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="popups/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#94e2d5,bold]󱂬 Popup Applications " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰾱 Neomutt Email" e "run-shell '$TMUX_CONF/modules/popups/neomutt.sh'" \
  "󰓷 SMS Messaging" m "run-shell '$TMUX_CONF/modules/popups/smstui.sh'" \
  " Documents" d "run-shell '$TMUX_CONF/modules/popups/notes.sh'" \
  "" \
  " File Explorer" f "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"#{pane_current_path}\" -T \" Yazi \" yazi'" \
  " Spotify Player" s "run-shell '$TMUX_CONF/modules/popups/spotify_player.sh'" \
  " System Monitor" y "run-shell '$TMUX_CONF/modules/popups/btop.sh'" \
  "" \
  " Hyprland Keybinds" h "run-shell '$TMUX_CONF/modules/popups/hyprland-keymaps.sh'" \
  " Design Colors" c "run-shell '$TMUX_CONF/modules/popups/colors.sh'" \
  " Nerd Fonts" n "run-shell 'tmux display-popup -E -w 90% -h 90% -T \" Nerd Fonts \" ~/.core/.sys/cfg/wezterm/scripts/nerdfont-browser/wezterm-browser.sh'"
