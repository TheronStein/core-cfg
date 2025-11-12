[](https://github.com/tmux/tmux/wiki/Recipes#create-a-new-pane-to-copy)

This opens a new pane with the history of the active pane - useful to copy multiple items from the history to the shell prompt.

Requires tmux 3.2 or later.

```
bind C {
	splitw -f -l30% ''
	set-hook -p pane-mode-changed 'if -F "#{!=:#{pane_mode},copy-mode}" "kill-pane"'
	copy-mode -s'{last}'
}
```