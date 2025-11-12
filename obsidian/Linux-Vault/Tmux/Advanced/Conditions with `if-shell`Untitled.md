---
topic: tmux
category: advanced
subject: conditions, shell, commands
url: https://github.com/tmux/tmux/wiki/Advanced-Use#conditions-with-if-shell
---

`if-shell` is a versatile command that allows a choice between two tmux commands to be made based on a shell command or (with `-F`) a format. The first argument is a condition, the second the command to run when it is true and the third the command to run when it is false. The third command may be left out.

If `-F` is given, the first condition argument is a format. A format is true if it expands to a string that is not empty and not 0. Without `-F`, the first argument is a shell command.

For example, a key binding to scroll to the top if a pane is in copy mode and do nothing if it is not:

```
bind T if -F '#{==:#{pane_mode},copy-mode}' 'send -X history-top'
```

Or to rename a window based on the time:

```
bind A if 'test `date +%H` -lt 12' 'renamew morning' 'renamew afternoon'
```

Note that `if-shell` is different from the `%if` directive. `%if` is interpreted when a configuration file is parsed; `if-shell` is a command that is run with other commands and can be used in key bindings.