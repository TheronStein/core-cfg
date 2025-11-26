#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Vertical Split" v "split-window -h" \
  "Horizontal Split" d "split-window -v" \
  "" \
  "New Window" c "command-prompt -p 'Window name:' 'new-window -n \"%%\" -c \"#{pane_current_path}\" -a -t \"{next}\"'" \
  "Rename Window" r "command-prompt -p 'New name:' 'rename-window \"%%\"'" \
  "Kill Window" x "confirm-before -p 'Kill window #W? (y/n)' kill-window" \
  "List All Windows" l "choose-tree -w" \
  "" \
  "Share window to session:" s "command-prompt -p 'Target session:' 'link-window -s . -t \"%%\"'" \
  "" \
  "Get Window from Session" g "display-popup -E -w 80% -h 80% '~/.core/cfg/tmux/scripts/pick-window.sh'" \
  "Move Window to Session" m "display-popup -E -w 80% -h 60% '~/.core/cfg/tmux/scripts/move-window.sh'" \
  "" \
  "Swap Windows (interactive)" S "run-shell '$TMUX_MENUS/window-swap-menu.sh'" \
  "Move Window (interactive)" M "run-shell '$TMUX_MENUS/window-move-menu.sh'" \
  "" \
  "Move Window Left (before prev)" q "run-shell '$TMUX_MENUS/window-move-left.sh'" \
  "Move Window Right (after next)" e "run-shell '$TMUX_MENUS/window-move-right.sh'" \
  "" \
  "Swap next Window and follow" N "swapw -d -t +1 \\; display '#{e|-:#{window_index},1} => #{window_index}'" \
  "Swap prev Window and follow" P "swapw -d -t -1 \\; display '#{window_index} <= #{e|+:#{window_index},1}'"

# Swap windows
# bind -N "Swap prev window" 'M-S-n' swapw -t -1
# bind -N "Swap next window" 'M-n' swapw -t +1p

# Window swapping
# bind -N "Swap prev window and follow" -r Q \
#   swapw -d -t -1 \; \
#   display "#{window_index} <= #{e|+:#{window_index},1}"

# bind -N "Swap next window and follow" -r E \
#   swapw -d -t +1 \; \
#   display "#{e|-:#{window_index},1} => #{window_index}"

# # Cycle windows/panes (no prefix)
# bind -n C-S-x selectp -t :.+ \; resizep -Z  # next pane zoom
# bind -n C-x selectp -t :.+                   # next pane
# bind -n C-e selectw -t :+                    # next window
# bind -n C-q selectw -t :-                    # previous window
