---
topic: tmux
category: advanced
subject: brackets, keys, commands
url: https://github.com/tmux/tmux/wiki/Advanced-Use#conditions-with-if-shell
---

[](https://github.com/tmux/tmux/wiki/Advanced-Use#quoting-with-)

tmux allows sections of a configuration file to be quoted using `{` and `}`. This is designed to allow complex commands and command sequences to be expressed more clearly, particularly where a command takes another command as an argument. Text between `{` and `}` is treated as a string without any modification.

So for a simple example, the `bind-key` command can take a command as its argument:

```
bind K {
	lsk
}
```

Or `if-shell` may be bound to a key:

```
bind K {
	if -F '#{==:#{window_name},ksh}' {
		kill-window
	} {
		display 'not killing window'
	}
}
```

This is equivalent to:

```
bind K if -F '#{==:#{window_name},ksh}' 'kill-window' "display 'not killing window'"
```