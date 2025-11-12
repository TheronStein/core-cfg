---
topic: tmux
category: advanced
subject: conditions, directives, commands
url: https://github.com/tmux/tmux/wiki/Advanced-Use#conditional-directives
---

tmux supports some special syntax in the configuration file to allow more flexible configuration. This is all processed when the configuration file is parsed.

Conditional directives allow parts of the configuration file to be processed only if a condition is true. A conditional directive looks like this:

```
%if #{format}
commands
%endif
```

If the given format is true (is not empty and not 0 after being expanded), then commands are executed. Additional branches of the `%if` may be given with `%elif` or a false branch with `%else`:

```
%if #{format}
commands
%elif #{format}
more commands
%else
yet more commands
%endif
```

Because these directives are processed when the configuration file is parsed, they can't use the results of commands - the commands (whether outside the conditional or in the true or false branch) are not executed until later when the configuration file has been completely parsed.

For example, this runs a different configuration file on a different host:

```
%if #{==:#{host_short},firsthost}
source ~/.tmux.conf.firsthost
%elif #{==:#{host_short},secondhost}
source ~/.tmux.conf.secondhost
%endif
```