---
topic: tmux
category: advanced
subject: commands, aliases
url: https://github.com/tmux/tmux/wiki/Advanced-Use#command-aliases
---
tmux allows custom commands by defining command aliases. Note this is different from the short alias of each command (such as `lsw` for `list-windows`). Command aliases are defined with the `command-alias` server option. This is an array option where each entry has a number.

The default has a few settings for convenience and a few for backwards compatibility:

```
$ tmux show -s command-alias
command-alias[0] split-pane=split-window
command-alias[1] splitp=split-window
command-alias[2] "server-info=show-messages -JT"
command-alias[3] "info=show-messages -JT"
command-alias[4] "choose-window=choose-tree -w"
command-alias[5] "choose-session=choose-tree -s"
```

Taking `command-alias[4]` as an example, this means that the `choose-window` command is expanded to `choose-tree -w`.

A custom command alias is added by adding a new index to the array. Because the defaults start at index 0, it is best to use higher numbers for additional command aliases:

```
:set -s command-alias[100] 'sv=splitw -v'
```

This option makes `sv` the same as `splitw -v`:

```
:sv
```

Any subsequent flags or arguments given to the entered command are appended to the replaced command. This is the same as `splitw -v -d`:

```
:sv -d
```