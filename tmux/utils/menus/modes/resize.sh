# Resize panes (uppercase with prefix - keeps your existing bindings)
bind -N "Resize pane upward" -r W resizep -U 2
bind -N "Resize pane downward" -r S resizep -D 2
bind -N "Resize pane leftward" -r A resizep -L 2
bind -N "Resize pane rightward" -r D resizep -R 2

# Pane resizing with Meta+Shift+W/A/S/D (no prefix needed)
bind -N "Resize pane up" -n M-W resize-pane -U 2
bind -N "Resize pane down" -n M-S resize-pane -D 2
bind -N "Resize pane left" -n M-A resize-pane -L 2
bind -N "Resize pane right" -n M-D resize-pane -R 2

bind -N "Resize pane leftward" -r A resizep -L 2
bind -N "Resize pane rightward" -r D resizep -R 2
bind -N "Resize pane downward" -r S resizep -D 2
bind -N "Resize pane upward" -r W resizep -U 2
