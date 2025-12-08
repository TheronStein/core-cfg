bind -N "List buffers" C-b lsb
bind -N "Interactive clipboard history" p pasteb # default: ]
bind -N "Delete paste buffer" + { deleteb; display "Deleted current buffer" }

bind-key -N "Copy to tmux clipboard" M-, {
run "tmux set-buffer -- \"$(xsel -ob)\""
display "Copied to tmux clipboard"
}
bind-key -N "Copy to system clipboard" M-. {
run 'tmux show-buffer | xsel -ib --trim'
display "Copied to system clipboard"
}

# bind 0 send C-l \; run 'tmux clear-history' \; display-message "Deleted current Tmux Clipboard History"

# Vim copy mode rebinds for

# Note: rectangle-toggle (aka Visual Block Mode) > hit v then C-v to trigger it

# Fix mouse

unbind -T root MouseDrag1Pane
unbind -T copy-mode-vi MouseDragEnd1Pane
bind -T copy-mode-vi MouseDown1Pane { selectp; send -X clear-selection }

bind -N "Select word" -T copy-mode-vi . send -X select-word
bind -N "Select line" -T copy-mode-vi V send -X select-line
bind -N "Start visual selection" -T copy-mode-vi v send -X begin-selection
bind -N "Start visual block" -T copy-mode-vi C-v { send -X rectangle-toggle; send -X begin-selection }
bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-and-cancel
bind -N "Copy to EOL" -T copy-mode-vi D send -X copy-end-of-line-and-cancel
bind -N "Copy line" -T copy-mode-vi Y send -X copy-line-and-cancel
bind -N "Copy word" -T copy-mode-vi S { send -X select-word; send -X copy-selection-and-cancel }
bind -N "Clear selection" -T copy-mode-vi Escape send -X clear-selection
bind -N "Cancel" -T copy-mode-vi i send -X cancel
bind -N "Cancel" -T copy-mode-vi q send -X cancel
bind -N "Goto EOL" -T copy-mode-vi L send -X end-of-line
bind -N "Goto BOL" -T copy-mode-vi H send -X start-of-line
bind -N "Goto MOL" -T copy-mode-vi z send -X middle-line
bind -N "Set mark" -T copy-mode-vi m send -X set-mark
bind -N "Goto mark" -T copy-mode-vi "'" send -X jump-to-mark
bind -N "Jump again" -T copy-mode-vi ';' send -X jump-again
bind -N "Jump reverse" -T copy-mode-vi , send -X jump-reverse
bind -N "Other end" -T copy-mode-vi o send -X other-end
bind -N "Half-page up" -T copy-mode-vi u send -X halfpage-up
bind -N "Half-page down" -T copy-mode-vi d send -X halfpage-down
bind -N "Copy" -T copy-mode-vi Enter send -X copy-pipe "xsel -ib"
bind -N "Copy" -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "xsel -ib"
