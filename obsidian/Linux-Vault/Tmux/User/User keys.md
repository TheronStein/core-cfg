---
topic: tmux
category: advanced
subject: user, commands, keys, customization
url: https://github.com/tmux/tmux/wiki/Advanced-Use#user-keys
---

tmux allows a set of custom key definitions. This is useful on the rare occasion where terminals send (or can be configured to send) unusual keys sequences that are not recognized by tmux by default.

User keys are added with the `user-keys` server option. This is an array option where each item is a sequence that tmux matches to a `UserN` key. For example:

```
set -s user-keys[0] '\033[foo'
```

With this, when the sequence `\033[foo` is received from the terminal, tmux will fire a `User0` key that can be bound as normal:

```
bind -n User0 list-keys
```

`user-keys[1]` maps to `User1`, `user-keys[2]` to `User2` and so on.