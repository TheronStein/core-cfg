---
topic: tmux
category: advanced
subjects: arrays, commands, scope
url: https://github.com/tmux/tmux/wiki/Advanced-Use#advanced-configuration
---

[](https://github.com/tmux/tmux/wiki/Advanced-Use#array-options)

Some tmux options may be set to multiple values, these are called array options. Each value has an index which is shown in `[` and `]` after the option name. Array indexes can have gaps, so an array with just index 0 and 999 is fine. The array options are `command-alias`, `terminal-features`, `terminal-overrides`, `status-format`, `update-environment` and `user-keys`. Every hook is also an array option.

An individual array index may be set or shown:

```
$ tmux set -g update-environment[999] FOO
$ tmux show -g update-environment[999]
update-environment[999] FOO
$ tmux set -gu update-environment[999]
```

Or all together by omitting the index. `-u` restores the entire array option to the default:

```
$ tmux show -g update-environment
update-environment[0] DISPLAY
update-environment[1] KRB5CCNAME
update-environment[2] SSH_ASKPASS
update-environment[3] SSH_AUTH_SOCK
update-environment[4] SSH_AGENT_PID
update-environment[5] SSH_CONNECTION
update-environment[6] WINDOWID
update-environment[7] XAUTHORITY
update-environment[999] FOO
$ tmux set -gu update-environment
$ tmux show -g update-environment
update-environment[0] DISPLAY
update-environment[1] KRB5CCNAME
update-environment[2] SSH_ASKPASS
update-environment[3] SSH_AUTH_SOCK
update-environment[4] SSH_AGENT_PID
update-environment[5] SSH_CONNECTION
update-environment[6] WINDOWID
update-environment[7] XAUTHORITY
```

The `-a` flag to `set-option` appends to an array option using the next free index:

```
$ tmux set -ag update-environment 'FOO'
$ tmux show -g update-environment
update-environment[0] DISPLAY
update-environment[1] KRB5CCNAME
update-environment[2] SSH_ASKPASS
update-environment[3] SSH_AUTH_SOCK
update-environment[4] SSH_AGENT_PID
update-environment[5] SSH_CONNECTION
update-environment[6] WINDOWID
update-environment[7] XAUTHORITY
update-environment[8] FOO
```

`-a` can accept multiple values separated by commas. For backwards compatibility with old tmux versions where arrays were kept as strings, a leading comma can be given:

```
$ tmux set -ag update-environment ',FOO,BAR'
```