This is a short list of the most commonly used tmux options, apart from style options:

|Option|Type|Description|
|---|---|---|
|`base-index`|session|If set, then windows indexes start from this instead of from 0|
|`buffer-limit`|server|The maximum number of automatic buffers to keep, the default is 50|
|`default-terminal`|server|The default value of the `TERM` environment variable inside tmux|
|`display-panes-time`|window|The time in milliseconds the pane numbers are shown for `C-b q`|
|`display-time`|session|The time in milliseconds for which messages on the status line are shown|
|`escape-time`|server|The time tmux waits after receiving an `Escape` key to see if it is part of a longer key sequence|
|`focus-events`|server|Whether focus key sequences are sent by tmux when the active pane changes and when received from the outside terminal if it supports them|
|`history-limit`|session|The maximum number of lines kept in the history for each pane|
|`mode-keys`|window|Whether _emacs(1)_ or _vi(1)_ key bindings are used in copy mode|
|`mouse`|session|If the mouse is enabled|
|`pane-border-status`|window|Whether a status line appears in every pane border: `top` or `bottom`|
|`prefix`|session|The prefix key, the default is `C-b`|
|`remain-on-exit`|window|Whether panes are automatically killed when the program running in the exits|
|`renumber-windows`|session|If `on`, windows are automatically renumbered to close any gaps in the window list|
|`set-clipboard`|server|Whether tmux should attempt to set the external _X(7)_ clipboard when text is copied and if the outside terminal supports it|
|`set-titles`|session|If `on`, tmux will set the title of the outside terminal|
|`status`|session|Whether the status line if visible|
|`status-keys`|session|Whether _emacs(1)_ or _vi(1)_ key bindings are used at the command prompt|
|`status-interval`|session|The maximum time in seconds before the status line is redrawn|
|`status-position`|session|The position of the status line: `top` or `bottom`|
|`synchronize-panes`|window|If `on`, typing in any pane in the window is sent to all panes in the window - care should be taken with this option!|
|`terminal-overrides`|server|Any capabilities tmux should override from the `TERM` given for the outside terminal|