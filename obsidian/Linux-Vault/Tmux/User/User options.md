---
topic: tmux
category: advanced
subject: user, commands, options, customization
url: https://github.com/tmux/tmux/wiki/Advanced-Use#user-options
---
tmux allows custom options to be set, these are called user options and can be pane, window, session or server options. All user options are strings and the names must be prefixed by `@`. There are no other restrictions on the value.

User options can be used to store a custom value from a script or key binding. Because tmux doesn't already know about the option name, the `-w` flag must be given for window options, or `-s` for server. For example to set an option on window 2 with the window name:

```
$ tmux set -Fwt:2 @myname '#{window_name}'
$ tmux show -wt:2 @myname
@mytime ksh
```

Or a global session option:

```
$ tmux set -g @myoption 'foo bar'
$ tmux show -g @myoption
foo bar
```

User options are useful for scripting, see [this section as well](https://github.com/tmux/tmux/wiki/Advanced-Use#getting-information).