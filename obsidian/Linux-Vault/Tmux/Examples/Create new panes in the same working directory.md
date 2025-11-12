[](https://github.com/tmux/tmux/wiki/Recipes#create-new-panes-in-the-same-working-directory)

This changes the default key bindings to add the `-c` flag to specify the working directory:

```
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -hc "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
```