#### Mouse copying behaviour

[](https://github.com/tmux/tmux/wiki/Getting-Started#mouse-copying-behaviour)

When dragging the mouse to copy text, tmux copies and exits copy mode when the mouse button is released. Alternative behaviours are configured by changing the `MouseDragEnd1Pane` key binding. The three most useful are:

1. Do not copy or clear the selection or exit copy mode when the mouse is released. The keyboard must be used to copy the selection:

```
unbind -Tcopy-mode MouseDragEnd1Pane
```

2. Copy and clear the selection but do not exit copy mode:

```
bind -Tcopy-mode MouseDragEnd1Pane send -X copy-selection
```

3. Copy but do not clear the selection:

```
bind -Tcopy-mode MouseDragEnd1Pane send -X copy-selection-no-clear
```