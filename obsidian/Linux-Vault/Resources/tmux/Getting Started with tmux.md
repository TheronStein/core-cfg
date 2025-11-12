
Launching tmux

`tmux new -s my_session`

## Exiting tmux


Close tmux by closing all windows or detaching and then:

`tmux kill-session -t my_session`

# Sessions, Windows, and Panes

### Creating
`tmux new-session -s <session-name>`
### Attach
`tmux attach-session -t <session-name>`
### Detach
`Ctrl+b d`

## Windows

Windows are individual instances inside a session. Think of them as tabs in a browser.

Creating Windows
`Ctrl+b c`

### Splitting Panes

Horizontal split: `Ctrl+b "`

Vertical split: `Ctrl+b %`

