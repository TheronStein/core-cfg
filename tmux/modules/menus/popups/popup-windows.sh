#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "󰾱 Neomutt Email" e "run-shell '~/.core/cfg/tmux/modules/popups/neomutt.sh'" \
  " Documents" d "run-shell '~/.core/cfg/tmux/modules/popups/notes.sh'" \
  "" \
  " File Explorer" f "run-shell -b 'tmux display-popup -E -w 90% -h 90% -x C -y C -T \" Yazi File Manager \" -b rounded \"yazi\"'" \
  " Spotify Player" s "run-shell '~/.core/cfg/tmux/modules/popups/spotify_player.sh'" \
  "System Monitor" y "run-shell '~/.core/cfg/tmux/modules/popups/btop.sh'" \
  "" \
  " Hyprland Keybinds" h "run-shell '~/.core/cfg/tmux/modules/popups/hyprland-keymaps.sh'" \
  "" \
  " Design Colors" c "run-shell '~/.core/cfg/tmux/modules/popups/colors.sh'" \
  " Nerd Fonts" n "run-shell -b 'tmux display-popup -E -w 90% -h 90% -x C -y C -T \" Nerd Font Browser \" -b rounded -S \"fg=#89b4fa,bg=#1e1e2e\" \"~/.core/cfg/wezterm/scripts/nerdfont-browser/wezterm-browser.sh\"'"
