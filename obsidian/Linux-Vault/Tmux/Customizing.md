#### Customizing the status line

[](https://github.com/tmux/tmux/wiki/Getting-Started#customizing-the-status-line)

There are many options for customizing the status line. The simplest options are:

- Turn the status line off: `set -g status off`
    
- Move it to the top: `set -g status-position top`
    
- Set the background colour to red: `set -g status-style bg=red`
    
- Change the text on the right to the time only: `set -g status-right '%H:%M'`
    
- Underline the current window: `set -g window-status-current-style 'underscore'`
    

#### Configuring the pane border

[](https://github.com/tmux/tmux/wiki/Getting-Started#configuring-the-pane-border)

The pane border colours may be set:

```
set -g pane-border-style fg=red
set -g pane-active-border-style 'fg=red,bg=yellow'
```

Each pane may be given a status line with the `pane-border-status` option, for example to show the pane title in bold:

```
set -g pane-border-status top
set -g pane-border-format '#[bold]#{pane_title}#[default]'
```